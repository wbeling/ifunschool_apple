import Foundation
import GameKit
import Combine
#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

class AchievementService: ObservableObject {
    static let shared = AchievementService()

    @Published var isAuthenticated: Bool = false
    @Published var unlockedAchievementTitle: String? = nil

    private var hasConfiguredAuthHandler = false
    #if canImport(UIKit)
    private weak var currentAuthViewController: UIViewController?
    #elseif canImport(AppKit)
    private weak var currentAuthViewController: NSViewController?
    #endif

    private let goldThresholds = [1, 5, 10, 15, 20, 25, 30, 40, 50]
    private let starThresholds = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 120, 140, 160, 180, 200]

    init() {
        authenticateLocalPlayer()
    }

    func authenticateLocalPlayer() {
        print("[GameCenter][tvOS/All] authenticateLocalPlayer() invoked. hasConfiguredAuthHandler=\(hasConfiguredAuthHandler)")
        guard !hasConfiguredAuthHandler else {
            print("[GameCenter][tvOS/All] Auth handler already configured, skipping duplicate registration.")
            return
        }
        hasConfiguredAuthHandler = true

        print("[GameCenter][tvOS/All] Registering GKLocalPlayer.local.authenticateHandler...")
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            DispatchQueue.main.async {
                print("[GameCenter][tvOS/All] authenticateHandler callback received:")
                print("[GameCenter][tvOS/All]   - viewController: \(String(describing: viewController))")
                if let error = error {
                    let nsErr = error as NSError
                    print("[GameCenter][tvOS/All]   - ERROR: domain=\(nsErr.domain), code=\(nsErr.code), desc=\(nsErr.localizedDescription)")
                } else {
                    print("[GameCenter][tvOS/All]   - error: nil")
                }
                print("[GameCenter][tvOS/All]   - GKLocalPlayer.local.isAuthenticated: \(GKLocalPlayer.local.isAuthenticated)")
                print("[GameCenter][tvOS/All]   - GKLocalPlayer.local.alias: '\(GKLocalPlayer.local.alias)'")
                print("[GameCenter][tvOS/All]   - GKLocalPlayer.local.displayName: '\(GKLocalPlayer.local.displayName)'")

                if let vc = viewController {
                    print("[GameCenter][tvOS/All] System returned authentication UI viewController: \(vc). Preparing presentation...")
                    self?.currentAuthViewController = vc
                    #if os(macOS)
                    if let window = NSApplication.shared.keyWindow ?? NSApplication.shared.mainWindow ?? NSApplication.shared.windows.first(where: { $0.isVisible }),
                       let contentVC = window.contentViewController {
                        contentVC.presentAsSheet(vc)
                    }
                    #elseif os(iOS) || os(tvOS)
                    print("[GameCenter][tvOS/iOS] Presenting auth view controller...")
                    self?.presentAuthViewController(vc)
                    #endif
                    return
                }

                // If authentication completed (or was cancelled), dismiss any lingering auth VC
                #if os(macOS)
                if let authVC = self?.currentAuthViewController {
                    authVC.dismiss(nil)
                    self?.currentAuthViewController = nil
                }
                #elseif os(iOS) || os(tvOS)
                if let authVC = self?.currentAuthViewController {
                    print("[GameCenter][tvOS/iOS] Dismissing currentAuthViewController: \(authVC)")
                    authVC.dismiss(animated: true) {
                        self?.currentAuthViewController = nil
                    }
                }
                #endif

                if GKLocalPlayer.local.isAuthenticated {
                    self?.isAuthenticated = true
                    let pid = GKLocalPlayer.local.gamePlayerID.isEmpty ? GKLocalPlayer.local.teamPlayerID : GKLocalPlayer.local.gamePlayerID
                    let alias = GKLocalPlayer.local.alias
                    let name = GKLocalPlayer.local.displayName.isEmpty ? (alias.isEmpty ? "Game Center" : alias) : GKLocalPlayer.local.displayName
                    print("[GameCenter][tvOS/All] SUCCESS: Player is authenticated! id=\(pid), alias=\(alias), displayName=\(name)")
                    ProfileManager.shared.updateGameCenterPlayer(id: pid, displayName: name)
                    #if os(tvOS)
                    DispatchQueue.main.async {
                        GKAccessPoint.shared.location = .topTrailing
                        GKAccessPoint.shared.showHighlights = true
                        GKAccessPoint.shared.isActive = true
                        print("[GameCenter][tvOS] Initialized GKAccessPoint.shared.isActive = true, location = .topTrailing")
                    }
                    #endif
                } else {
                    print("[GameCenter][tvOS/All] NOTICE: Player is NOT authenticated with Game Center.")
                    self?.isAuthenticated = false
                }
            }
        }
    }

    #if os(iOS) || os(tvOS)
    private func presentAuthViewController(_ vc: UIViewController, retryCount: Int = 0) {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let windowScene = scenes.first { $0.activationState == .foregroundActive } ?? scenes.first
        print("[GameCenter][tvOS/iOS] presentAuthViewController(retryCount=\(retryCount)): totalScenes=\(scenes.count), activeScene=\(String(describing: windowScene))")

        if let rootVC = windowScene?.windows.first(where: { $0.isKeyWindow })?.rootViewController ?? windowScene?.windows.first?.rootViewController {
            var topVC = rootVC
            while let presented = topVC.presentedViewController {
                topVC = presented
            }
            print("[GameCenter][tvOS/iOS] Presenting auth UI on topVC=\(topVC) (class: \(type(of: topVC)))")
            topVC.present(vc, animated: true) {
                print("[GameCenter][tvOS/iOS] Auth UI presentation completed.")
            }
        } else if retryCount < 10 {
            print("[GameCenter][tvOS/iOS] No rootVC found yet, retrying in 0.3s (attempt \(retryCount + 1))...")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.presentAuthViewController(vc, retryCount: retryCount + 1)
            }
        } else {
            print("[GameCenter][tvOS/iOS] ERROR: Could not find rootVC to present auth VC after 10 attempts!")
        }
    }
    #endif

    private func getUnlockedIDs(playerID: String = ScoreStorage.shared.activePlayerID) -> Set<String> {
        let key = "ifunschool_unlocked_achievement_ids_\(playerID)"
        if let array = UserDefaults.standard.array(forKey: key) as? [String] {
            return Set(array)
        }
        return []
    }

    private func saveUnlockedIDs(_ set: Set<String>, playerID: String = ScoreStorage.shared.activePlayerID) {
        let key = "ifunschool_unlocked_achievement_ids_\(playerID)"
        UserDefaults.standard.set(Array(set), forKey: key)
    }

    @discardableResult
    func evaluateAndReport(
        totalGoldStars: Int,
        totalSilverStars: Int,
        totalScore: Double,
        affectedLevel: GameLevel? = nil,
        playerID: String = ScoreStorage.shared.activePlayerID
    ) -> [String] {
        var unlockedSet = getUnlockedIDs(playerID: playerID)
        var newlyUnlockedTitles: [String] = []
        var achievementsToReport: [GKAchievement] = []

        func processAchievement(identifier: String, currentVal: Double, targetVal: Double, title: String) {
            let isAlreadyUnlocked = unlockedSet.contains(identifier)
            guard !isAlreadyUnlocked else { return }

            let percent = min(100.0, (currentVal / targetVal) * 100.0)

            let achievement = GKAchievement(identifier: identifier)
            achievement.percentComplete = percent
            achievement.showsCompletionBanner = true
            achievementsToReport.append(achievement)

            if percent >= 100.0 {
                unlockedSet.insert(identifier)
                newlyUnlockedTitles.append(title)
            }
        }

        // 1. Evaluate Gold Star Milestones
        for threshold in goldThresholds {
            let identifier = "pl.beling.ifunschool.gold\(threshold)"
            processAchievement(
                identifier: identifier,
                currentVal: Double(totalGoldStars),
                targetVal: Double(threshold),
                title: "Gold Star Master (\(threshold) Gold Stars)"
            )
        }

        // 2. Evaluate Silver/Total Star Milestones
        for threshold in starThresholds {
            let identifier = "pl.beling.ifunschool.stars\(threshold)"
            processAchievement(
                identifier: identifier,
                currentVal: Double(totalSilverStars),
                targetVal: Double(threshold),
                title: "Star Collector (\(threshold) Stars)"
            )
        }

        // 3. Evaluate All Category Progress Milestones (10%, 50%, 100%)
        let allCategories: [(GameType, GameLevel, String, String)] = [
            (.addition, .easy, "add", "Dodawanie"),
            (.subtraction, .easy, "sub", "Odejmowanie"),
            (.multiplication, .easy, "mult", "Mnożenie"),
            (.division, .easy, "div", "Dzielenie"),
            (.flags, .godlike, "flags", "Flagi"),
            (.capitals, .godlike, "capitals", "Państwa - miasta"),
            (.chemSymbols, .godlike, "elements", "Pierwiastki")
        ]

        let dict = ItemProgressTracker.shared.getProgressDict()
        let milestones = [10, 50, 100]

        for (gameType, level, prefix, name) in allCategories {
            let keys = QuestionGenerator.shared.itemKeysForLevel(gameType: gameType, level: level)
            guard !keys.isEmpty else { continue }
            let correctCount = keys.filter { dict[$0]?.status == .correct }.count
            let currentPercent = (Double(correctCount) / Double(keys.count)) * 100.0

            for m in milestones {
                let identifier = "pl.beling.ifunschool.\(prefix)\(m)"
                processAchievement(
                    identifier: identifier,
                    currentVal: currentPercent,
                    targetVal: Double(m),
                    title: "\(name) (\(m)%)"
                )
            }
        }

        // 4. Evaluate Streak Milestones (Day 1 to Day 30)
        let currentStreak = StreakTracker.shared.streakCount
        for day in 1...30 {
            let identifier = "pl.beling.ifunschool.streak\(day)"
            processAchievement(
                identifier: identifier,
                currentVal: Double(currentStreak),
                targetVal: Double(day),
                title: "Dzień \(day) Streak"
            )
        }

        // Save newly unlocked achievement IDs to persistent cache
        saveUnlockedIDs(unlockedSet, playerID: playerID)

        // Report to GameKit if authenticated
        if isAuthenticated {
            print("[GameCenter][Score/Ach] Evaluating achievements & scores for GameKit. TotalScore=\(totalScore), achievementsToReport=\(achievementsToReport.count)")
            if !achievementsToReport.isEmpty {
                GKAchievement.report(achievementsToReport) { error in
                    if let error = error {
                        print("[GameCenter][Score/Ach] GKAchievement.report ERROR: \(error.localizedDescription)")
                    } else {
                        print("[GameCenter][Score/Ach] GKAchievement.report SUCCESS for \(achievementsToReport.count) achievements.")
                    }
                }
            }

            // Submit leaderboard scores:
            // Always update overall totals leaderboard if totalScore > 0
            if totalScore > 0 {
                let leaderBoardID = "pl.beling.ifunschool.totals"
                GKLeaderboard.submitScore(Int(totalScore * 100), context: 0, player: GKLocalPlayer.local, leaderboardIDs: [leaderBoardID]) { error in
                    if let error = error {
                        print("[GameCenter][Score/Ach] GKLeaderboard.submitScore totals ERROR: \(error.localizedDescription)")
                    } else {
                        print("[GameCenter][Score/Ach] GKLeaderboard.submitScore totals SUCCESS: \(Int(totalScore * 100)) pts")
                    }
                }
            }

            // Only submit score for affected level (e.g. playing on hard only updates hard leaderboard, not easy/medium/etc.)
            let levelsToUpdate: [GameLevel]
            if let affectedLevel = affectedLevel {
                levelsToUpdate = [affectedLevel]
            } else {
                levelsToUpdate = GameLevel.allCases
            }

            for level in levelsToUpdate {
                let lvlScore = ScoreStorage.shared.totalScore(for: level)
                if lvlScore > 0 {
                    let lvlID = "pl.beling.ifunschool.totalLvl\(level.rawValue)"
                    GKLeaderboard.submitScore(Int(lvlScore * 100), context: 0, player: GKLocalPlayer.local, leaderboardIDs: [lvlID]) { error in
                        if let error = error {
                            print("[GameCenter][Score/Ach] GKLeaderboard.submitScore level \(level.rawValue) ERROR: \(error.localizedDescription)")
                        } else {
                            print("[GameCenter][Score/Ach] GKLeaderboard.submitScore level \(level.rawValue) SUCCESS: \(Int(lvlScore * 100)) pts")
                        }
                    }
                }
            }
        }

        if let first = newlyUnlockedTitles.last {
            DispatchQueue.main.async {
                self.unlockedAchievementTitle = first
            }
        }

        return newlyUnlockedTitles
    }
}

// MARK: - GameCenter Presenter (macOS, tvOS & iOS)

@MainActor
final class GameCenterPresenter: NSObject, ObservableObject, GKGameCenterControllerDelegate {
    static let shared = GameCenterPresenter()

    @Published var showAuthenticationAlert: Bool = false

    func show(state: GKGameCenterViewControllerState, leaderboardID: String? = nil) {
        print("[GameCenterPresenter] show() called: state=\(state.rawValue), leaderboardID=\(leaderboardID ?? "nil")")
        print("[GameCenterPresenter] GKLocalPlayer.local.isAuthenticated=\(GKLocalPlayer.local.isAuthenticated), alias='\(GKLocalPlayer.local.alias)'")

        guard GKLocalPlayer.local.isAuthenticated else {
            print("[GameCenterPresenter] BLOCKED: Local player is not authenticated. Triggering showAuthenticationAlert = true")
            showAuthenticationAlert = true
            return
        }

        #if os(macOS)
        let window = NSApplication.shared.keyWindow ?? NSApplication.shared.mainWindow ?? NSApplication.shared.windows.first(where: { $0.isVisible })

        let gcVC: GKGameCenterViewController
        if let leaderID = leaderboardID, !leaderID.isEmpty {
            gcVC = GKGameCenterViewController(leaderboardID: leaderID, playerScope: .global, timeScope: .allTime)
        } else {
            gcVC = GKGameCenterViewController(state: state)
        }
        gcVC.gameCenterDelegate = self

        let dc = GKDialogController.shared()
        dc.parentWindow = window
        let presented = dc.present(gcVC)
        if !presented {
            GKAccessPoint.shared.parentWindow = window
            if #available(macOS 15.0, *), let leaderID = leaderboardID, !leaderID.isEmpty {
                GKAccessPoint.shared.trigger(leaderboardID: leaderID, playerScope: .global, timeScope: .allTime) {}
            } else {
                GKAccessPoint.shared.trigger(state: state) {}
            }
        }

        #elseif os(tvOS)
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        print("[GameCenterPresenter][tvOS] Available window scenes count: \(scenes.count)")
        let windowScene = scenes.first { $0.activationState == .foregroundActive } ?? scenes.first
        let window = windowScene?.windows.first(where: { $0.isKeyWindow }) ?? windowScene?.windows.first
        print("[GameCenterPresenter][tvOS] Selected parent window: \(String(describing: window)), isKey=\(window?.isKeyWindow ?? false)")

        if let window = window {
            print("[GameCenterPresenter][tvOS] Setting GKAccessPoint.shared.parentWindow = \(window)")
            GKAccessPoint.shared.parentWindow = window
        }

        // On tvOS, GKAccessPoint MUST be active before calling trigger
        GKAccessPoint.shared.isActive = true

        let triggerAction = {
            print("[GameCenterPresenter][tvOS] GKAccessPoint state: isActive=\(GKAccessPoint.shared.isActive), isVisible=\(GKAccessPoint.shared.isVisible), location=\(GKAccessPoint.shared.location.rawValue)")

            if #available(tvOS 18.0, *), let leaderID = leaderboardID, !leaderID.isEmpty {
                print("[GameCenterPresenter][tvOS] Invoking GKAccessPoint.shared.trigger(leaderboardID: \(leaderID), playerScope: .global, timeScope: .allTime)...")
                GKAccessPoint.shared.trigger(leaderboardID: leaderID, playerScope: .global, timeScope: .allTime) {
                    print("[GameCenterPresenter][tvOS] HANDLER: GKAccessPoint trigger(leaderboardID:) dismissed / finished.")
                }
            } else {
                print("[GameCenterPresenter][tvOS] Invoking GKAccessPoint.shared.trigger(state: \(state.rawValue))...")
                GKAccessPoint.shared.trigger(state: state) {
                    print("[GameCenterPresenter][tvOS] HANDLER: GKAccessPoint trigger(state:) dismissed / finished.")
                }
            }
            print("[GameCenterPresenter][tvOS] Trigger call dispatched to GKAccessPoint.")
        }

        // On tvOS, a presented modal sheet (e.g. SettingsView or ProfileView) traps focus in the Focus Engine.
        // Triggering GameOverlayUI while a modal is present causes a focus deadlock and freezes gamed/GameOverlayUI.
        if let presented = window?.rootViewController?.presentedViewController {
            if presented.isBeingDismissed {
                print("[GameCenterPresenter][tvOS] Modal is already being dismissed. Waiting for dismissal before triggering...")
                if let coordinator = presented.transitionCoordinator {
                    coordinator.animate(alongsideTransition: nil) { _ in
                        print("[GameCenterPresenter][tvOS] Modal dismissal finished. Triggering dashboard now...")
                        triggerAction()
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        print("[GameCenterPresenter][tvOS] Delayed trigger after modal dismissal...")
                        triggerAction()
                    }
                }
            } else {
                print("[GameCenterPresenter][tvOS] Dismissing modal presentedViewController (\(type(of: presented))) to yield focus...")
                presented.dismiss(animated: true) {
                    print("[GameCenterPresenter][tvOS] Modal dismissed. Triggering dashboard now...")
                    triggerAction()
                }
            }
        } else {
            triggerAction()
        }

        #elseif os(iOS)
        let windowScene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
            ?? UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first

        guard let rootVC = windowScene?.windows.first(where: { $0.isKeyWindow })?.rootViewController ?? windowScene?.windows.first?.rootViewController else {
            return
        }

        var topVC = rootVC
        while let presented = topVC.presentedViewController {
            topVC = presented
        }

        let gcVC: GKGameCenterViewController
        if let leaderID = leaderboardID, !leaderID.isEmpty {
            gcVC = GKGameCenterViewController(leaderboardID: leaderID, playerScope: .global, timeScope: .allTime)
        } else {
            gcVC = GKGameCenterViewController(state: state)
        }
        gcVC.gameCenterDelegate = self

        topVC.present(gcVC, animated: true)
        #endif
    }

    #if os(macOS)
    nonisolated func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        DispatchQueue.main.async {
            GKDialogController.shared().dismiss(self)
        }
    }
    #elseif canImport(UIKit)
    nonisolated func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        DispatchQueue.main.async {
            gameCenterViewController.dismiss(animated: true)
        }
    }
    #endif
}

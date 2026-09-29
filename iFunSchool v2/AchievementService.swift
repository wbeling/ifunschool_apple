import Foundation
import GameKit
import Combine

class AchievementService: ObservableObject {
    static let shared = AchievementService()

    @Published var isAuthenticated: Bool = false
    @Published var unlockedAchievementTitle: String? = nil

    private let goldThresholds = [1, 5, 10, 15, 20, 25, 30, 40, 50]
    private let starThresholds = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 120, 140, 160, 180, 200]

    init() {
        authenticateLocalPlayer()
    }

    func authenticateLocalPlayer() {
        GKLocalPlayer.local.authenticateHandler = { [weak self] _, error in
            DispatchQueue.main.async {
                if GKLocalPlayer.local.isAuthenticated {
                    self?.isAuthenticated = true
                    let pid = GKLocalPlayer.local.gamePlayerID.isEmpty ? GKLocalPlayer.local.teamPlayerID : GKLocalPlayer.local.gamePlayerID
                    let alias = GKLocalPlayer.local.alias
                    let name = GKLocalPlayer.local.displayName.isEmpty ? (alias.isEmpty ? "Game Center" : alias) : GKLocalPlayer.local.displayName
                    ProfileManager.shared.updateGameCenterPlayer(id: pid, displayName: name)
                } else {
                    self?.isAuthenticated = false
                }
            }
        }
    }

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
    func evaluateAndReport(totalGoldStars: Int, totalSilverStars: Int, totalScore: Double, playerID: String = ScoreStorage.shared.activePlayerID) -> [String] {
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
        if isAuthenticated && !achievementsToReport.isEmpty {
            GKAchievement.report(achievementsToReport) { error in
                if let error = error {
                    print("GameKit Achievement Report Error: \(error.localizedDescription)")
                }
            }

            // Submit leaderboard scores (Overall + Per Level)
            let leaderBoardID = "pl.beling.ifunschool.totals"
            GKLeaderboard.submitScore(Int(totalScore * 100), context: 0, player: GKLocalPlayer.local, leaderboardIDs: [leaderBoardID]) { error in
                if let error = error {
                    print("GameKit Leaderboard Submit Error: \(error.localizedDescription)")
                }
            }

            for level in GameLevel.allCases {
                let lvlScore = ScoreStorage.shared.totalScore(for: level)
                if lvlScore > 0 {
                    let lvlID = "pl.beling.ifunschool.totalLvl\(level.rawValue)"
                    GKLeaderboard.submitScore(Int(lvlScore * 100), context: 0, player: GKLocalPlayer.local, leaderboardIDs: [lvlID]) { _ in }
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

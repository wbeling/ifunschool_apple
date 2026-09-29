import Foundation
import GameKit

struct SavedScoreRecord: Codable {
    let gameType: Int
    let gameLevel: Int
    var topStars: Int
    var topScore: Double
    var topTime: Int
}

class ScoreStorage {
    static let shared = ScoreStorage()

    private let legacyUserDefaultsKey = "ifunschool_v2_saved_scores"
    private(set) var activePlayerID: String = "local_user"
    private var userDefaultsKey: String {
        return "ifunschool_v2_saved_scores_\(activePlayerID)"
    }

    private(set) var scoresDict: [String: SavedScoreRecord] = [:]

    init() {
        setupCloudSyncObserver()
        loadAllScores()
    }

    // MARK: - User Switcher (Game Center / Profile switch support)
    func switchUser(playerID: String?) {
        let newID = (playerID != nil && !playerID!.isEmpty) ? playerID! : "local_user"
        guard newID != activePlayerID else { return }

        activePlayerID = newID
        loadAllScores()
        StreakTracker.shared.refreshStreakData(for: newID)
        NotificationCenter.default.post(name: NSNotification.Name("iFunSchoolScoreUpdated"), object: nil)
    }

    // MARK: - iCloud Observer Setup
    private func setupCloudSyncObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(iCloudDataDidChange(_:)),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: NSUbiquitousKeyValueStore.default
        )
        NSUbiquitousKeyValueStore.default.synchronize()
    }

    @objc private func iCloudDataDidChange(_ notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.loadAllScores()
            NotificationCenter.default.post(name: NSNotification.Name("iFunSchoolScoreUpdated"), object: nil)
        }
    }

    // MARK: - Load and Merge (Local + iCloud)
    func loadAllScores() {
        // 1. Read Local Scores
        var localDict: [String: SavedScoreRecord] = [:]
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([String: SavedScoreRecord].self, from: data) {
            localDict = decoded
        } else if activePlayerID == "local_user",
                  let legacyData = UserDefaults.standard.data(forKey: legacyUserDefaultsKey),
                  let legacyDecoded = try? JSONDecoder().decode([String: SavedScoreRecord].self, from: legacyData) {
            // Migrate legacy scores to local_user
            localDict = legacyDecoded
        } else {
            #if DEBUG
            localDict = seedInitialScoresDict()
            #endif
        }

        // 2. Read iCloud Scores
        var cloudDict: [String: SavedScoreRecord] = [:]
        if let cloudData = NSUbiquitousKeyValueStore.default.data(forKey: userDefaultsKey),
           let cloudDecoded = try? JSONDecoder().decode([String: SavedScoreRecord].self, from: cloudData) {
            cloudDict = cloudDecoded
        }

        // 3. Merge Local and iCloud Scores (keeping best score, stars, time)
        self.scoresDict = merge(local: localDict, cloud: cloudDict)

        // 4. Persist merged result locally and to iCloud
        persist()
    }

    private func merge(local: [String: SavedScoreRecord], cloud: [String: SavedScoreRecord]) -> [String: SavedScoreRecord] {
        var result = local

        for (key, cloudRecord) in cloud {
            if var localRecord = result[key] {
                // Keep highest score
                localRecord.topScore = max(localRecord.topScore, cloudRecord.topScore)
                // Keep highest stars
                localRecord.topStars = max(localRecord.topStars, cloudRecord.topStars)
                // Keep best time (lowest time for 5 stars, ignoring 0)
                if cloudRecord.topStars == 5 {
                    if localRecord.topTime == 0 || (cloudRecord.topTime > 0 && cloudRecord.topTime < localRecord.topTime) {
                        localRecord.topTime = cloudRecord.topTime
                    }
                }
                result[key] = localRecord
            } else {
                result[key] = cloudRecord
            }
        }
        return result
    }

    private func seedInitialScoresDict() -> [String: SavedScoreRecord] {
        let initialList: [SavedScoreRecord] = [
            SavedScoreRecord(gameType: 1, gameLevel: 0, topStars: 5, topScore: 2450.0, topTime: 42),
            SavedScoreRecord(gameType: 2, gameLevel: 0, topStars: 4, topScore: 1820.0, topTime: 55),
            SavedScoreRecord(gameType: 3, gameLevel: 0, topStars: 3, topScore: 1400.0, topTime: 68),
            SavedScoreRecord(gameType: 4, gameLevel: 0, topStars: 5, topScore: 3100.0, topTime: 38),
            SavedScoreRecord(gameType: 13, gameLevel: 0, topStars: 5, topScore: 3400.0, topTime: 32),
            SavedScoreRecord(gameType: 15, gameLevel: 0, topStars: 4, topScore: 2100.0, topTime: 48)
        ]

        var dict: [String: SavedScoreRecord] = [:]
        for record in initialList {
            let key = "\(record.gameType)_\(record.gameLevel)"
            dict[key] = record
        }
        return dict
    }

    private func persist() {
        if let encoded = try? JSONEncoder().encode(scoresDict) {
            // Save to Local UserDefaults
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)

            // Sync to iCloud Key-Value Store
            NSUbiquitousKeyValueStore.default.set(encoded, forKey: userDefaultsKey)
            NSUbiquitousKeyValueStore.default.synchronize()
        }
    }

    @discardableResult
    func saveScore(gameType: GameType, level: GameLevel, score: Double, stars: Int, time: Int) -> (isNewHighScore: Bool, isNewStarsRecord: Bool) {
        let key = "\(gameType.rawValue)_\(level.rawValue)"
        var isNewHighScore = false
        var isNewStarsRecord = false

        if var existing = scoresDict[key] {
            if score > existing.topScore {
                existing.topScore = score
                isNewHighScore = true
            }
            if stars > existing.topStars {
                existing.topStars = stars
                isNewStarsRecord = true
            }
            if stars == 5 && (time < existing.topTime || existing.topTime == 0) {
                existing.topTime = time
            }
            scoresDict[key] = existing
        } else {
            let newRecord = SavedScoreRecord(
                gameType: gameType.rawValue,
                gameLevel: level.rawValue,
                topStars: stars,
                topScore: score,
                topTime: stars == 5 ? time : 0
            )
            scoresDict[key] = newRecord
            isNewHighScore = score > 0
            isNewStarsRecord = stars > 0
        }

        persist()
        NotificationCenter.default.post(name: NSNotification.Name("iFunSchoolScoreUpdated"), object: nil)

        return (isNewHighScore, isNewStarsRecord)
    }

    var totalGoldStars: Int {
        scoresDict.values.filter { $0.topStars == 5 }.count
    }

    @MainActor
    var effectiveGoldStars: Int {
        let raw = totalGoldStars
        if StoreKitService.shared.isStarLimitUnlocked {
            return raw
        } else {
            return min(raw, 15)
        }
    }

    @MainActor
    var isStarLimitReached: Bool {
        return !StoreKitService.shared.isStarLimitUnlocked && totalGoldStars >= 15
    }

    var totalSilverStars: Int {
        scoresDict.values.reduce(0) { sum, record in
            if record.topStars == 5 {
                return sum + 4
            } else {
                return sum + record.topStars
            }
        }
    }

    var totalScore: Double {
        scoresDict.values.reduce(0.0) { $0 + $1.topScore }
    }

    func totalScore(for level: GameLevel) -> Double {
        scoresDict.values
            .filter { $0.gameLevel == level.rawValue }
            .reduce(0.0) { $0 + $1.topScore }
    }
}

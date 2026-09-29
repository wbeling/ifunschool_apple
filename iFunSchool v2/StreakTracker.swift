import Foundation

// MARK: - Played Date Record Structure
struct PlayedDateRecord: Codable, Hashable, Equatable {
    let day: Int
    let month: Int
    let year: Int

    var dateString: String {
        return String(format: "%04d-%02d-%02d", year, month, day)
    }

    init(day: Int, month: Int, year: Int) {
        self.day = day
        self.month = month
        self.year = year
    }

    init?(date: Date) {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        guard let y = components.year, let m = components.month, let d = components.day else {
            return nil
        }
        self.year = y
        self.month = m
        self.day = d
    }

    init?(dateString: String) {
        let parts = dateString.components(separatedBy: "-")
        guard parts.count == 3,
              let y = Int(parts[0]),
              let m = Int(parts[1]),
              let d = Int(parts[2]) else {
            return nil
        }
        self.year = y
        self.month = m
        self.day = d
    }
}

// MARK: - Streak Tracker (with iCloud Key-Value Sync & Achievement Auto-Evaluation)
class StreakTracker: ObservableObject {
    static let shared = StreakTracker()

    @Published var streakCount: Int = 0
    @Published var hasPlayedToday: Bool = false
    @Published var currentGoalDay: Int = 1
    @Published var playedDatesRecords: [PlayedDateRecord] = []

    private let lastUptimeKey = "ifunschool_streak_last_uptime"
    private let lastServerDateKey = "ifunschool_streak_last_server_date"

    init() {
        setupCloudSyncObserver()
        refreshStreakData()
    }

    private func storageKey(for playerID: String) -> String {
        return "ifunschool_v2_played_dates_\(playerID)"
    }

    // MARK: - Load and Merge Played Dates (Local + iCloud)
    func getPlayedDates(for playerID: String = ScoreStorage.shared.activePlayerID) -> Set<PlayedDateRecord> {
        let key = storageKey(for: playerID)

        // 1. Read Local Played Dates
        var localSet = Set<PlayedDateRecord>()
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([PlayedDateRecord].self, from: data) {
            localSet = Set(decoded)
        } else if let stringArray = UserDefaults.standard.array(forKey: key) as? [String] {
            // Legacy Migration from String array
            let migrated = stringArray.compactMap { PlayedDateRecord(dateString: $0) }
            localSet = Set(migrated)
        }

        // 2. Read Cloud Played Dates
        var cloudSet = Set<PlayedDateRecord>()
        if let cloudData = NSUbiquitousKeyValueStore.default.data(forKey: key),
           let cloudDecoded = try? JSONDecoder().decode([PlayedDateRecord].self, from: cloudData) {
            cloudSet = Set(cloudDecoded)
        }

        // 3. Union Merge across Local & iCloud
        let mergedSet = localSet.union(cloudSet)

        // 4. Persist merged result locally & in iCloud
        persistPlayedDates(mergedSet, for: playerID)

        return mergedSet
    }

    private func persistPlayedDates(_ dates: Set<PlayedDateRecord>, for playerID: String) {
        let key = storageKey(for: playerID)
        let array = Array(dates).sorted { r1, r2 in
            if r1.year != r2.year { return r1.year < r2.year }
            if r1.month != r2.month { return r1.month < r2.month }
            return r1.day < r2.day
        }

        if let data = try? JSONEncoder().encode(array) {
            UserDefaults.standard.set(data, forKey: key)
            NSUbiquitousKeyValueStore.default.set(data, forKey: key)
            NSUbiquitousKeyValueStore.default.synchronize()
        }
    }

    // MARK: - Refresh Streak State
    func refreshStreakData(for playerID: String = ScoreStorage.shared.activePlayerID) {
        let datesSet = getPlayedDates(for: playerID)
        let count = min(30, datesSet.count)
        let sortedRecords = Array(datesSet).sorted { r1, r2 in
            if r1.year != r2.year { return r1.year < r2.year }
            if r1.month != r2.month { return r1.month < r2.month }
            return r1.day < r2.day
        }

        getTrustedDate { [weak self] trustedDate in
            guard let self = self else { return }
            let todayRecord = PlayedDateRecord(date: trustedDate)
            let playedToday = (todayRecord != nil) ? datesSet.contains(todayRecord!) : false

            DispatchQueue.main.async {
                self.streakCount = count
                self.hasPlayedToday = playedToday
                self.currentGoalDay = min(30, count + 1)
                self.playedDatesRecords = sortedRecords
                NotificationCenter.default.post(name: NSNotification.Name("iFunSchoolStreakUpdated"), object: nil)

                // Report streak milestones whenever streak data is refreshed
                let totalGold = ScoreStorage.shared.totalGoldStars
                let totalSilver = ScoreStorage.shared.totalSilverStars
                let totalScore = ScoreStorage.shared.totalScore
                AchievementService.shared.evaluateAndReport(
                    totalGoldStars: totalGold,
                    totalSilverStars: totalSilver,
                    totalScore: totalScore,
                    playerID: playerID
                )
            }
        }
    }

    // MARK: - Record Game Completion (min 1 star)
    func recordGameCompleted(stars: Int, playerID: String = ScoreStorage.shared.activePlayerID, completion: (() -> Void)? = nil) {
        guard stars > 0 else {
            completion?()
            return
        }

        getTrustedDate { [weak self] trustedDate in
            guard let self = self else {
                completion?()
                return
            }
            guard let todayRecord = PlayedDateRecord(date: trustedDate) else {
                completion?()
                return
            }

            var datesSet = self.getPlayedDates(for: playerID)
            let wasNewDay = !datesSet.contains(todayRecord)

            if wasNewDay {
                datesSet.insert(todayRecord)
                self.persistPlayedDates(datesSet, for: playerID)

                let newCount = min(30, datesSet.count)
                let sortedRecords = Array(datesSet).sorted { r1, r2 in
                    if r1.year != r2.year { return r1.year < r2.year }
                    if r1.month != r2.month { return r1.month < r2.month }
                    return r1.day < r2.day
                }

                DispatchQueue.main.async {
                    self.streakCount = newCount
                    self.hasPlayedToday = true
                    self.currentGoalDay = min(30, newCount + 1)
                    self.playedDatesRecords = sortedRecords
                    NotificationCenter.default.post(name: NSNotification.Name("iFunSchoolStreakUpdated"), object: nil)

                    // Report achievements after streakCount is updated
                    let totalGold = ScoreStorage.shared.totalGoldStars
                    let totalSilver = ScoreStorage.shared.totalSilverStars
                    let totalScore = ScoreStorage.shared.totalScore
                    AchievementService.shared.evaluateAndReport(
                        totalGoldStars: totalGold,
                        totalSilverStars: totalSilver,
                        totalScore: totalScore,
                        playerID: playerID
                    )

                    completion?()
                }
            } else {
                DispatchQueue.main.async {
                    completion?()
                }
            }
        }
    }

    // MARK: - iCloud Sync Observer
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
            self?.refreshStreakData()
        }
    }

    // MARK: - Anti-Cheat Date Verification (Network HTTP Header + SystemUptime Fallback)
    func getTrustedDate(completion: @escaping (Date) -> Void) {
        guard let url = URL(string: "https://www.apple.com") else {
            completion(fallbackDateFromUptime())
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 3.0

        URLSession.shared.dataTask(with: request) { [weak self] _, response, error in
            guard let self = self else { return }
            if let httpResponse = response as? HTTPURLResponse,
               let dateHeader = httpResponse.allHeaderFields["Date"] as? String {
                let rfcFormatter = DateFormatter()
                rfcFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
                rfcFormatter.locale = Locale(identifier: "en_US_POSIX")
                if let serverDate = rfcFormatter.date(from: dateHeader) {
                    let nowUptime = ProcessInfo.processInfo.systemUptime
                    UserDefaults.standard.set(nowUptime, forKey: self.lastUptimeKey)
                    UserDefaults.standard.set(serverDate, forKey: self.lastServerDateKey)
                    completion(serverDate)
                    return
                }
            }
            completion(self.fallbackDateFromUptime())
        }.resume()
    }

    private func fallbackDateFromUptime() -> Date {
        let lastUptime = UserDefaults.standard.double(forKey: lastUptimeKey)
        let lastServerDate = UserDefaults.standard.object(forKey: lastServerDateKey) as? Date
        let currentUptime = ProcessInfo.processInfo.systemUptime

        if lastUptime > 0, let anchorDate = lastServerDate {
            let elapsedSeconds = max(0, currentUptime - lastUptime)
            return anchorDate.addingTimeInterval(elapsedSeconds)
        }
        return Date()
    }
}

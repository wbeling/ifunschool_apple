import Foundation

enum ItemStatus: String, Codable {
    case notAsked = "notAsked"
    case incorrect = "incorrect"
    case correct = "correct"
}

struct ItemProgressRecord: Codable {
    let itemKey: String
    var status: ItemStatus
    var lastAnsweredDate: Date
}

class ItemProgressTracker {
    static let shared = ItemProgressTracker()

    private func storageKey(for playerID: String) -> String {
        return "ifunschool_v2_item_progress_\(playerID)"
    }

    func getProgressDict(for playerID: String = ScoreStorage.shared.activePlayerID) -> [String: ItemProgressRecord] {
        let key = storageKey(for: playerID)
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([String: ItemProgressRecord].self, from: data) {
            return decoded
        }
        return [:]
    }

    func getStatus(for itemKey: String, playerID: String = ScoreStorage.shared.activePlayerID) -> ItemStatus {
        let dict = getProgressDict(for: playerID)
        return dict[itemKey]?.status ?? .notAsked
    }

    func updateStatus(itemKey: String, isCorrect: Bool, playerID: String = ScoreStorage.shared.activePlayerID) {
        guard !itemKey.isEmpty else { return }
        var dict = getProgressDict(for: playerID)
        let newStatus: ItemStatus = isCorrect ? .correct : .incorrect
        let record = ItemProgressRecord(itemKey: itemKey, status: newStatus, lastAnsweredDate: Date())
        dict[itemKey] = record

        let key = storageKey(for: playerID)
        if let encoded = try? JSONEncoder().encode(dict) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
        NotificationCenter.default.post(name: NSNotification.Name("iFunSchoolItemProgressUpdated"), object: nil)
    }
}

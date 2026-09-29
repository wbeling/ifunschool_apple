import Foundation
import StoreKit

class ReviewPromptService {
    static let shared = ReviewPromptService()

    private let totalGamesKey = "v2_total_games_completed"
    private let lastPromptDateKey = "v2_last_review_prompt_date"

    private let sessionStartDate = Date()

    private init() {}

    var totalGamesCompleted: Int {
        get {
            UserDefaults.standard.integer(forKey: totalGamesKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: totalGamesKey)
        }
    }

    private var lastPromptDate: Date? {
        get {
            UserDefaults.standard.object(forKey: lastPromptDateKey) as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: lastPromptDateKey)
        }
    }

    func recordGameCompletedAndCheckReview() {
        totalGamesCompleted += 1
        checkAndPromptReview()
    }

    func checkAndPromptReview() {
        
        // 1. Metric: At least 15 completed games
        guard totalGamesCompleted >= 15 else { return }

        // 2. Metric: Session duration at least 2 minutes (120 seconds) today
        let sessionDuration = Date().timeIntervalSince(sessionStartDate)
        guard sessionDuration >= 120.0 else { return }

        // 3. Metric: Not more often than once per day (86400 seconds)
        if let lastDate = lastPromptDate {
            let timeSinceLastPrompt = Date().timeIntervalSince(lastDate)
            guard timeSinceLastPrompt >= 86400.0 else { return }
        }

        // Record prompt date and request review
        lastPromptDate = Date()
        
        #if(os(iOS))
        // TODO: implement for tvOS
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
        #endif
    }
}

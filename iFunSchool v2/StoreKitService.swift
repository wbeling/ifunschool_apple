import Foundation
import StoreKit
import Combine

@MainActor
class StoreKitService: ObservableObject {
    static let shared = StoreKitService()

    static let subMonthlyID = "pl.beling.ifunschool.sub.monthly"
    static let sub3mID = "pl.beling.ifunschool.sub.3m"
    static let subYearlyID = "pl.beling.ifunschool.sub.yearly"

    static let allSubscriptionIDs: Set<String> = [
        subMonthlyID,
        sub3mID,
        subYearlyID
    ]

    static let godlikeProductID = "pl.beling.ifunschool.godlike"
    static let unlockProductID = "pl.beling.ifunschool.unlock"

    private let godlikeLegacyKey = "is_godlike_legacy_purchased"
    private let starLimitLegacyKey = "is_star_limit_legacy_purchased"

    @Published var subscriptions: [Product] = []
    @Published var introOfferEligibility: [String: Bool] = [:]
    @Published var godlikeProduct: Product? = nil
    @Published var unlockProduct: Product? = nil
    @Published var isLoading: Bool = false
    @Published var purchaseError: String? = nil

    @Published var isSubscriptionActive: Bool = false {
        didSet {
            objectWillChange.send()
            NotificationCenter.default.post(name: NSNotification.Name("iFunSchoolScoreUpdated"), object: nil)
        }
    }

    @Published var isGodlikeLegacyPurchased: Bool {
        didSet {
            UserDefaults.standard.set(isGodlikeLegacyPurchased, forKey: godlikeLegacyKey)
            objectWillChange.send()
            NotificationCenter.default.post(name: NSNotification.Name("iFunSchoolScoreUpdated"), object: nil)
        }
    }

    @Published var isStarLimitLegacyPurchased: Bool {
        didSet {
            UserDefaults.standard.set(isStarLimitLegacyPurchased, forKey: starLimitLegacyKey)
            objectWillChange.send()
            NotificationCenter.default.post(name: NSNotification.Name("iFunSchoolScoreUpdated"), object: nil)
        }
    }

    private var transactionTask: Task<Void, Never>? = nil

    private init() {
        self.isGodlikeLegacyPurchased = UserDefaults.standard.bool(forKey: godlikeLegacyKey)
        self.isStarLimitLegacyPurchased = UserDefaults.standard.bool(forKey: starLimitLegacyKey)

        listenForTransactions()
        Task {
            await fetchProducts()
            await updatePurchasedStateFromAppStore()
        }
    }

    deinit {
        transactionTask?.cancel()
    }

    var isGodlikeUnlocked: Bool {
        isSubscriptionActive || isGodlikeLegacyPurchased
    }

    var isStarLimitUnlocked: Bool {
        isSubscriptionActive || isStarLimitLegacyPurchased
    }

    var goldStarsLimit: Int {
        return 90
    }

    // MARK: - Product Fetching & Duration Sorting
    func fetchProducts() async {
        isLoading = true
        purchaseError = nil
        do {
            var requestedIDs = StoreKitService.allSubscriptionIDs
            requestedIDs.insert(StoreKitService.godlikeProductID)
            requestedIDs.insert(StoreKitService.unlockProductID)

            let fetchedProducts = try await Product.products(for: requestedIDs)

            self.godlikeProduct = fetchedProducts.first(where: { $0.id == StoreKitService.godlikeProductID })
            self.unlockProduct = fetchedProducts.first(where: { $0.id == StoreKitService.unlockProductID })

            // Filter auto-renewable subscriptions returned by Apple as available for this user
            let subProducts = fetchedProducts.filter { product in
                product.subscription != nil && StoreKitService.allSubscriptionIDs.contains(product.id)
            }

            // Check introductory offer eligibility dynamically from Apple
            var eligibilities: [String: Bool] = [:]
            for product in subProducts {
                if let sub = product.subscription {
                    eligibilities[product.id] = await sub.isEligibleForIntroOffer
                }
            }
            self.introOfferEligibility = eligibilities

            // Sort products from shortest subscription duration to longest
            self.subscriptions = subProducts.sorted { [weak self] p1, p2 in
                let d1 = self?.periodInMonths(for: p1) ?? 0.0
                let d2 = self?.periodInMonths(for: p2) ?? 0.0
                return d1 < d2
            }
            isLoading = false
        } catch {
            print("Failed to fetch StoreKit products: \(error)")
            purchaseError = error.localizedDescription
            isLoading = false
        }
    }

    // Calculate percentage savings relative to the base monthly tier
    func savingsPercentage(for product: Product) -> Int? {
        guard let baseProduct = subscriptions.first(where: { periodInMonths(for: $0) == 1.0 }),
              product.id != baseProduct.id else {
            return nil
        }

        let basePricePerMonth = Double(truncating: baseProduct.price as NSDecimalNumber)
        let thisMonths = periodInMonths(for: product)
        guard thisMonths > 0 else { return nil }

        let thisPricePerMonth = Double(truncating: product.price as NSDecimalNumber) / thisMonths
        let ratio = thisPricePerMonth / basePricePerMonth
        let savings = Int(round((1.0 - ratio) * 100.0))
        return savings > 0 ? savings : nil
    }

    func monthlyEquivalentPriceString(for product: Product) -> String? {
        let months = periodInMonths(for: product)
        guard months > 0 else { return nil }
        let pricePerMonth = Double(truncating: product.price as NSDecimalNumber) / months

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceFormatStyle.locale
        return formatter.string(from: NSNumber(value: pricePerMonth))
    }

    func periodInMonths(for product: Product) -> Double {
        guard let subscription = product.subscription else { return 0.0 }
        switch subscription.subscriptionPeriod.unit {
        case .day:
            return Double(subscription.subscriptionPeriod.value) / 30.0
        case .week:
            return Double(subscription.subscriptionPeriod.value) / 4.0
        case .month:
            return Double(subscription.subscriptionPeriod.value)
        case .year:
            return Double(subscription.subscriptionPeriod.value) * 12.0
        @unknown default:
            return 0.0
        }
    }

    // MARK: - Purchase Flow
    func purchase(_ product: Product) async -> Bool {
        isLoading = true
        purchaseError = nil
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await updatePurchasedStateFromAppStore()
                await transaction.finish()
                isLoading = false
                return true

            case .userCancelled:
                isLoading = false
                return false

            case .pending:
                isLoading = false
                return false

            @unknown default:
                isLoading = false
                return false
            }
        } catch {
            print("Purchase failed: \(error)")
            purchaseError = error.localizedDescription
            isLoading = false
            return false
        }
    }

    // MARK: - Restore Purchases
    func restorePurchases() async {
        isLoading = true
        purchaseError = nil
        do {
            try await AppStore.sync()
            await updatePurchasedStateFromAppStore()
            isLoading = false
        } catch {
            print("Restore purchases failed: \(error)")
            purchaseError = error.localizedDescription
            isLoading = false
        }
    }

    // MARK: - Verification & Transaction Listener
    private func listenForTransactions() {
        transactionTask = Task.detached { [weak self] in
            for await result in Transaction.updates {
                do {
                    guard let self = self else { break }
                    let transaction = try self.checkVerified(result)
                    await self.updatePurchasedStateFromAppStore()
                    await transaction.finish()
                } catch {
                    print("Transaction verification failed: \(error)")
                }
            }
        }
    }

    func updatePurchasedStateFromAppStore() async {
        var hasActiveSub = false
        var hasGodlikeLegacy = UserDefaults.standard.bool(forKey: godlikeLegacyKey)
        var hasStarLimitLegacy = UserDefaults.standard.bool(forKey: starLimitLegacyKey)

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }

            if transaction.revocationDate == nil {
                if StoreKitService.allSubscriptionIDs.contains(transaction.productID) {
                    hasActiveSub = true
                } else {
                    switch transaction.productID {
                    case StoreKitService.godlikeProductID:
                        hasGodlikeLegacy = true

                    case StoreKitService.unlockProductID:
                        hasStarLimitLegacy = true

                    default:
                        break
                    }
                }
            }
        }

        self.isSubscriptionActive = hasActiveSub
        self.isGodlikeLegacyPurchased = hasGodlikeLegacy
        self.isStarLimitLegacyPurchased = hasStarLimitLegacy
    }

    private nonisolated func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let safe):
            return safe
        }
    }
}

// MARK: - Introductory Offer Models & Helpers
struct IntroOfferDetails {
    let introPriceString: String
    let introDurationString: String
    let regularPriceString: String
    let regularPeriodString: String
    let isFreeTrial: Bool
    let fullNoticeText: String
    let subscribeButtonText: String
}

extension StoreKitService {
    func isEligibleForIntroOffer(for product: Product) async -> Bool {
        guard let subscription = product.subscription else { return false }
        return await subscription.isEligibleForIntroOffer
    }

    func introOfferDetails(for product: Product) -> IntroOfferDetails? {
        guard let subscription = product.subscription,
              let intro = subscription.introductoryOffer,
              introOfferEligibility[product.id] ?? true else {
            return nil
        }

        let introDuration = formattedIntroDuration(for: intro)
        let regularPeriod = formattedPeriod(for: subscription.subscriptionPeriod)
        let isFreeTrial = (intro.paymentMode == .freeTrial)

        let fullNotice: String
        let buttonText: String

        if isFreeTrial {
            let format = NSLocalizedString("store_intro_trial_banner_format", comment: "Free trial banner")
            fullNotice = String(format: format, introDuration, product.displayPrice, regularPeriod)
            buttonText = NSLocalizedString("store_subscribe_trial_button", comment: "Start free trial")
        } else {
            let format = NSLocalizedString("store_intro_promo_banner_format", comment: "Promo banner")
            fullNotice = String(format: format, introDuration, intro.displayPrice, product.displayPrice, regularPeriod)

            let btnFormat = NSLocalizedString("store_subscribe_intro_button_format", comment: "Get promo button")
            buttonText = String(format: btnFormat, intro.displayPrice, introDuration)
        }

        return IntroOfferDetails(
            introPriceString: intro.displayPrice,
            introDurationString: introDuration,
            regularPriceString: product.displayPrice,
            regularPeriodString: regularPeriod,
            isFreeTrial: isFreeTrial,
            fullNoticeText: fullNotice,
            subscribeButtonText: buttonText
        )
    }

    private func formattedIntroDuration(for intro: Product.SubscriptionOffer) -> String {
        let totalCount = intro.period.value * intro.periodCount
        var dateComponents = DateComponents()
        switch intro.period.unit {
        case .day:
            dateComponents.day = totalCount
        case .week:
            dateComponents.weekOfMonth = totalCount
        case .month:
            dateComponents.month = totalCount
        case .year:
            dateComponents.year = totalCount
        @unknown default:
            return "\(totalCount)"
        }
        let formatter = DateComponentsFormatter()
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .full
        return formatter.string(from: dateComponents) ?? "\(totalCount)"
    }

    private func formattedPeriod(for period: Product.SubscriptionPeriod) -> String {
        var dateComponents = DateComponents()
        switch period.unit {
        case .day:
            dateComponents.day = period.value
        case .week:
            dateComponents.weekOfMonth = period.value
        case .month:
            dateComponents.month = period.value
        case .year:
            dateComponents.year = period.value
        @unknown default:
            return ""
        }
        let formatter = DateComponentsFormatter()
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .full
        return formatter.string(from: dateComponents) ?? "\(period.value)"
    }
}

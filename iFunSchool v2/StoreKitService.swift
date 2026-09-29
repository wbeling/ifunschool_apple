import Foundation
import StoreKit
import Combine

@MainActor
class StoreKitService: ObservableObject {
    static let shared = StoreKitService()

    static let subMonthlyID = "pl.beling.ifunschool.sub.monthly"
    static let subQuarterlyID = "pl.beling.ifunschool.sub.quarterly"
    static let subYearlyID = "pl.beling.ifunschool.sub.yearly"

    static let godlikeProductID = "pl.beling.ifunschool.godlike"
    static let unlockProductID = "pl.beling.ifunschool.unlock"

    private let godlikeLegacyKey = "is_godlike_legacy_purchased"
    private let starLimitLegacyKey = "is_star_limit_legacy_purchased"

    @Published var subscriptions: [Product] = []
    @Published var godlikeProduct: Product? = nil
    @Published var unlockProduct: Product? = nil
    @Published var allowLegacyPurchases: Bool = true
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

    var canBuyGodlike: Bool {
        return allowLegacyPurchases && !isGodlikeLegacyPurchased
    }

    var canBuyStarLimit: Bool {
        return allowLegacyPurchases && !isStarLimitLegacyPurchased
    }

    func isPurchaseAvailable(for productID: String) -> Bool {
        guard allowLegacyPurchases else { return false }
        switch productID {
        case StoreKitService.godlikeProductID:
            return !isGodlikeLegacyPurchased
        case StoreKitService.unlockProductID:
            return !isStarLimitLegacyPurchased
        default:
            return false
        }
    }

    // MARK: - Product Fetching & Duration Sorting
    func fetchProducts() async {
        isLoading = true
        purchaseError = nil
        do {
            let fetchedProducts = try await Product.products(for: [
                StoreKitService.subMonthlyID,
                StoreKitService.subQuarterlyID,
                StoreKitService.subYearlyID,
                StoreKitService.godlikeProductID,
                StoreKitService.unlockProductID
            ])

            self.godlikeProduct = fetchedProducts.first(where: { $0.id == StoreKitService.godlikeProductID })
            self.unlockProduct = fetchedProducts.first(where: { $0.id == StoreKitService.unlockProductID })

            let subProducts = fetchedProducts.filter {
                $0.id == StoreKitService.subMonthlyID ||
                $0.id == StoreKitService.subQuarterlyID ||
                $0.id == StoreKitService.subYearlyID
            }

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
                switch transaction.productID {
                case StoreKitService.subMonthlyID,
                     StoreKitService.subQuarterlyID,
                     StoreKitService.subYearlyID:
                    hasActiveSub = true

                case StoreKitService.godlikeProductID:
                    hasGodlikeLegacy = true

                case StoreKitService.unlockProductID:
                    hasStarLimitLegacy = true

                default:
                    break
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
              let intro = subscription.introductoryOffer else {
            return nil
        }

        let isPolish = (Locale.current.languageCode == "pl")
        let introDuration = formattedIntroDuration(for: intro, isPolish: isPolish)
        let regularPeriod = formattedPeriod(for: subscription.subscriptionPeriod, isPolish: isPolish)
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

    private func formattedIntroDuration(for intro: Product.SubscriptionOffer, isPolish: Bool) -> String {
        let totalCount = intro.period.value * intro.periodCount
        switch intro.period.unit {
        case .month:
            if totalCount == 1 {
                return isPolish ? "Pierwszy miesiąc" : "First month"
            } else if isPolish {
                return "Pierwsze \(totalCount) mies."
            } else {
                return "First \(totalCount) months"
            }
        case .year:
            if totalCount == 1 {
                return isPolish ? "Pierwszy rok" : "First year"
            } else if isPolish {
                return "Pierwsze \(totalCount) lata"
            } else {
                return "First \(totalCount) years"
            }
        case .week:
            if totalCount == 1 {
                return isPolish ? "Pierwszy tydzień" : "First week"
            } else if isPolish {
                return "Pierwsze \(totalCount) tyg."
            } else {
                return "First \(totalCount) weeks"
            }
        case .day:
            if totalCount == 1 {
                return isPolish ? "Pierwszy dzień" : "First day"
            } else if isPolish {
                return "Pierwsze \(totalCount) dni"
            } else {
                return "First \(totalCount) days"
            }
        @unknown default:
            return isPolish ? "Okres promocyjny" : "Intro period"
        }
    }

    private func formattedPeriod(for period: Product.SubscriptionPeriod, isPolish: Bool) -> String {
        switch period.unit {
        case .day:
            if period.value == 1 { return isPolish ? "dzień" : "day" }
            return isPolish ? "\(period.value) dni" : "\(period.value) days"
        case .week:
            if period.value == 1 { return isPolish ? "tydzień" : "week" }
            return isPolish ? "\(period.value) tyg." : "\(period.value) weeks"
        case .month:
            if period.value == 1 { return isPolish ? "miesiąc" : "month" }
            if period.value == 3 { return isPolish ? "kwartał" : "quarter" }
            if period.value == 12 { return isPolish ? "rok" : "year" }
            return isPolish ? "\(period.value) mies." : "\(period.value) months"
        case .year:
            if period.value == 1 { return isPolish ? "rok" : "year" }
            return isPolish ? "\(period.value) lat" : "\(period.value) years"
        @unknown default:
            return isPolish ? "okres" : "period"
        }
    }
}

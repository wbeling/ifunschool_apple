import SwiftUI
import StoreKit

struct StoreView: View {
    @StateObject private var storeKitService = StoreKitService.shared
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        #if os(macOS)
        VStack(spacing: 0) {
            // macOS Window Header Bar
            HStack {
                Text(LocalizedStringKey("nav_store"))
                    .font(.title2.bold())
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text(LocalizedStringKey("nav_done"))
                        .font(.headline)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)

            Divider()

            ScrollView {
                VStack(spacing: 24) {
                    // Hero Header Card
                    heroHeader

                    // Error Alert Banner
                    if let errorMsg = storeKitService.purchaseError {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(errorMsg)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                    }

                    // Subscription Section (Subscriber Manage Card OR Purchase Options)
                    // subscriptionSection

                    // Restored / Legacy Purchases Card
                    if storeKitService.isGodlikeLegacyPurchased || storeKitService.isStarLimitLegacyPurchased || storeKitService.canBuyGodlike || storeKitService.canBuyStarLimit {
                        RestoredLegacyPurchasesCard()
                            .frame(maxWidth: .infinity)
                    }

                    // Standalone Restore Purchases Button at Bottom
                    restoreButton

                    // Footer Notice
                    Text(LocalizedStringKey("store_footer_notice"))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                }
                #if os(tvOS)
                .padding(.horizontal, 56)
                .padding(.vertical, 36)
                #else
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                #endif
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(FunColors.bgColor.ignoresSafeArea())
        #if os(macOS)
        .frame(minWidth: 640, idealWidth: 700, minHeight: 700, idealHeight: 780)
        #elseif os(tvOS)
        .frame(minWidth: 1100, idealWidth: 1300, maxWidth: 1500, minHeight: 800, idealHeight: 900, maxHeight: 1000)
        #endif
        .onAppear {
            Task {
                await storeKitService.fetchProducts()
            }
        }
        #else
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Hero Header Card
                    heroHeader

                    // Error Alert Banner
                    if let errorMsg = storeKitService.purchaseError {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(errorMsg)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                    }

                    // Subscription Section (Subscriber Manage Card OR Purchase Options)
                    // subscriptionSection

                    // Restored / Legacy Purchases Card
                    if storeKitService.isGodlikeLegacyPurchased || storeKitService.isStarLimitLegacyPurchased || storeKitService.canBuyGodlike || storeKitService.canBuyStarLimit {
                        RestoredLegacyPurchasesCard()
                    }

                    // Standalone Restore Purchases Button at Bottom
                    restoreButton

                    // Footer Notice
                    Text(LocalizedStringKey("store_footer_notice"))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                }
                .padding(.horizontal, 16)
            }
            .background(FunColors.bgColor.ignoresSafeArea())
            .navigationTitle(LocalizedStringKey("nav_store"))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text(LocalizedStringKey("nav_done"))
                            .font(.headline)
                    }
                }
            }
            .onAppear {
                Task {
                    await storeKitService.fetchProducts()
                }
            }
        }
        #endif
    }

    // MARK: - Hero Header
    private var heroHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [FunColors.chalkboardGreen, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "crown.fill")
                    .font(.system(size: 38))
                    .foregroundColor(.yellow)
            }

            Text(LocalizedStringKey("store_title"))
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            Text(LocalizedStringKey("store_subtitle"))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
        }
        .padding(.top, 12)
    }

    // MARK: - Subscription Section (Active Card or Tiers List)
    @ViewBuilder
    private var subscriptionSection: some View {
        if storeKitService.isSubscriptionActive {
            // Active Subscriber Card + Manage Subscription Button (No purchase choices shown)
            VStack(spacing: 16) {
                HStack(spacing: 14) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 38))
                        .foregroundColor(.green)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(LocalizedStringKey("store_active_subscriber_title"))
                            .font(.title3.bold())
                            .foregroundColor(.green)

                        Text(LocalizedStringKey("store_active_subscriber_subtext"))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                }
                .padding(18)
                .background(Color.green.opacity(0.12))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.green.opacity(0.4), lineWidth: 1.5)
                )

                Button(action: {
                    manageSubscription()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "gearshape.fill")
                            .font(.headline)
                        Text(LocalizedStringKey("store_manage_subscription_button"))
                            .font(.headline.bold())
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(14)
                }
                .buttonStyle(.plain)
            }
        } else {
            // Subscription Tiers List (Sorted Shortest to Longest)
            VStack(alignment: .leading, spacing: 14) {
                Text(LocalizedStringKey("store_choose_subscription"))
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)

                ForEach(storeKitService.subscriptions, id: \.id) { product in
                    SubscriptionCardRow(product: product)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func manageSubscription() {
        #if os(iOS)
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            Task {
                do {
                    try await AppStore.showManageSubscriptions(in: scene)
                } catch {
                    if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                        await UIApplication.shared.open(url)
                    }
                }
            }
        } else if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
            Task {
                await UIApplication.shared.open(url)
            }
        }
        #elseif os(macOS)
        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
            NSWorkspace.shared.open(url)
        }
        #elseif os(tvOS)
        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
            Task {
                await UIApplication.shared.open(url)
            }
        }
        #endif
    }

    // MARK: - Standalone Restore Button
    private var restoreButton: some View {
        Button(action: {
            Task {
                await storeKitService.restorePurchases()
            }
        }) {
            HStack(spacing: 6) {
                if storeKitService.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "arrow.clockwise.circle")
                }
                Text(LocalizedStringKey("store_restore_purchases"))
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundColor(.blue)
            .padding(.vertical, 6)
        }
        .disabled(storeKitService.isLoading)
    }
}

// MARK: - Introductory Offer Badge Subview
struct IntroOfferBadge: View {
    let details: IntroOfferDetails

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top, spacing: 6) {
                Image(systemName: details.isFreeTrial ? "gift.fill" : "sparkles")
                    .font(.subheadline)
                    .foregroundColor(details.isFreeTrial ? .green : .orange)

                VStack(alignment: .leading, spacing: 2) {
                    Text(details.fullNoticeText)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(details.isFreeTrial ? .green : .primary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(LocalizedStringKey("store_intro_once_notice"))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(details.isFreeTrial ? Color.green.opacity(0.12) : Color.orange.opacity(0.12))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(details.isFreeTrial ? Color.green.opacity(0.3) : Color.orange.opacity(0.4), lineWidth: 1)
        )
    }
}

// MARK: - Subscription Card Component
struct SubscriptionCardRow: View {
    let product: Product
    @StateObject private var storeKitService = StoreKitService.shared

    var body: some View {
        let isSubscribed = storeKitService.isSubscriptionActive
        let savingsPercent = storeKitService.savingsPercentage(for: product)
        let monthlyEquiv = storeKitService.monthlyEquivalentPriceString(for: product)
        let introDetails = storeKitService.introOfferDetails(for: product)

        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(subscriptionTitle(for: product))
                            .font(.headline.bold())

                        // Percentage Savings Badge (for longer tiers)
                        if let savings = savingsPercent {
                            Text(String(format: NSLocalizedString("store_save_percentage", comment: "Save %"), savings))
                                .font(.caption2.bold())
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }

                    if let equiv = monthlyEquiv, storeKitService.periodInMonths(for: product) > 1.0 {
                        Text(String(format: NSLocalizedString("store_monthly_equivalent_format", comment: "Monthly equiv"), equiv))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(product.displayPrice)
                        .font(.title3.bold())
                        .foregroundColor(FunColors.chalkboardGreen)
                    
                    if let details = introDetails {
                        Text("\(details.introDurationString): \(details.introPriceString)")
                            .font(.caption2.bold())
                            .foregroundColor(.orange)
                    }
                }
            }

            // Introductory Offer Banner
            if let details = introDetails {
                IntroOfferBadge(details: details)
            }

            // Family Sharing Badge if enabled for this product
            if product.isFamilyShareable {
                HStack(spacing: 6) {
                    Image(systemName: "person.2.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Text(LocalizedStringKey("store_family_sharing_included"))
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.blue)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }

            // Subscribe Button
            Button(action: {
                Task {
                    _ = await storeKitService.purchase(product)
                }
            }) {
                HStack {
                    Spacer()
                    if storeKitService.isLoading {
                        ProgressView()
                            .scaleEffect(0.9)
                            .tint(.white)
                    } else {
                        let btnLabel = introDetails?.subscribeButtonText ?? String(format: NSLocalizedString("store_subscribe_button", comment: "Subscribe"), product.displayPrice)
                        Text(btnLabel)
                            .font(.headline.bold())
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                .frame(minHeight: 48)
                .background(isSubscribed ? Color.gray : FunColors.chalkboardGreen)
                .cornerRadius(12)
            }
            .buttonStyle(FunActionButtonStyle(cornerRadius: 12))
            .disabled(storeKitService.isLoading)
        }
        .padding(18)
        .background(FunColors.bgColor2)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(introDetails != nil ? Color.orange.opacity(0.8) : (savingsPercent != nil ? Color.orange.opacity(0.6) : Color.clear), lineWidth: introDetails != nil ? 2 : 1.5)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }

    private func subscriptionTitle(for product: Product) -> String {
        switch product.id {
        case StoreKitService.subMonthlyID:
            return NSLocalizedString("store_period_monthly", comment: "Monthly")
        case StoreKitService.subQuarterlyID:
            return NSLocalizedString("store_period_quarterly", comment: "Quarterly")
        case StoreKitService.subYearlyID:
            return NSLocalizedString("store_period_yearly", comment: "Yearly")
        default:
            return product.displayName
        }
    }
}

// MARK: - Restored Legacy Purchases Card (Visible when items restored or available to buy)
struct RestoredLegacyPurchasesCard: View {
    @StateObject private var storeKitService = StoreKitService.shared

    private var godlikeTitle: String {
        storeKitService.godlikeProduct?.displayName ?? NSLocalizedString("store_legacy_godlike", comment: "")
    }

    private var starLimitTitle: String {
        storeKitService.unlockProduct?.displayName ?? NSLocalizedString("store_legacy_limit", comment: "")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(LocalizedStringKey("store_legacy_restored_header"))
                .font(.headline.bold())
                .foregroundColor(.green)

            Divider()

            // Godlike Difficulty Item
            if storeKitService.isGodlikeLegacyPurchased {
                HStack {
                    Label {
                        Text(godlikeTitle)
                            .font(.subheadline)
                    } icon: {
                        Image(systemName: "bolt.shield.fill")
                            .foregroundColor(FunColors.chalkboardGreen)
                    }

                    Spacer()

                    Text(LocalizedStringKey("store_status_restored"))
                        .font(.caption.bold())
                        .foregroundColor(.green)
                }
            } else if storeKitService.canBuyGodlike {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .top) {
                        Label {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(godlikeTitle)
                                    .font(.subheadline.bold())
                                Text(LocalizedStringKey("store_desc_godlike"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        } icon: {
                            Image(systemName: "bolt.shield.fill")
                                .foregroundColor(FunColors.chalkboardGreen)
                        }

                        Spacer()
                    }

                    if let product = storeKitService.godlikeProduct {
                        Button(action: {
                            Task {
                                _ = await storeKitService.purchase(product)
                            }
                        }) {
                            HStack {
                                Spacer()
                                if storeKitService.isLoading {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .tint(.white)
                                } else {
                                    let btnText = String(format: NSLocalizedString("store_buy_button_format", comment: "Kup (cena)"), product.displayPrice)
                                    Text(btnText)
                                        .font(.headline.bold())
                                        .foregroundColor(.white)
                                }
                                Spacer()
                            }
                            .frame(minHeight: 44)
                            .background(FunColors.chalkboardGreen)
                            .cornerRadius(10)
                        }
                        .buttonStyle(FunActionButtonStyle(cornerRadius: 10))
                        .disabled(storeKitService.isLoading)
                    }
                }
            }

            if (storeKitService.isGodlikeLegacyPurchased || storeKitService.canBuyGodlike) &&
               (storeKitService.isStarLimitLegacyPurchased || storeKitService.canBuyStarLimit) {
                Divider()
            }

            // Star Limit Boost Item
            if storeKitService.isStarLimitLegacyPurchased {
                HStack {
                    Label {
                        Text(starLimitTitle)
                            .font(.subheadline)
                    } icon: {
                        Image(systemName: "star.fill")
                            .foregroundColor(.orange)
                    }

                    Spacer()

                    Text(LocalizedStringKey("store_status_restored"))
                        .font(.caption.bold())
                        .foregroundColor(.green)
                }
            } else if storeKitService.canBuyStarLimit {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .top) {
                        Label {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(starLimitTitle)
                                    .font(.subheadline.bold())
                                Text(LocalizedStringKey("store_desc_unlock_stars"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        } icon: {
                            Image(systemName: "star.fill")
                                .foregroundColor(.orange)
                        }

                        Spacer()
                    }

                    if let product = storeKitService.unlockProduct {
                        Button(action: {
                            Task {
                                _ = await storeKitService.purchase(product)
                            }
                        }) {
                            HStack {
                                Spacer()
                                if storeKitService.isLoading {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .tint(.white)
                                } else {
                                    let btnText = String(format: NSLocalizedString("store_buy_button_format", comment: "Kup (cena)"), product.displayPrice)
                                    Text(btnText)
                                        .font(.headline.bold())
                                        .foregroundColor(.white)
                                }
                                Spacer()
                            }
                            .frame(minHeight: 44)
                            .background(Color.orange)
                            .cornerRadius(10)
                        }
                        .buttonStyle(FunActionButtonStyle(cornerRadius: 10))
                        .disabled(storeKitService.isLoading)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.green.opacity(0.08))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.green.opacity(0.3), lineWidth: 1)
        )
    }
}

struct StoreView_Previews: PreviewProvider {
    static var previews: some View {
        StoreView()
    }
}

import SwiftUI
import StoreKit

struct ContentView: View {
    @StateObject private var viewModel = GameListViewModel()
    @StateObject private var storeKitService = StoreKitService.shared

    @State private var isShowingSettings = false
    @State private var isShowingStore = false
    @State private var isShowingProgressGrid = false
    @State private var isShowingProfile = false
    @State private var isShowingStreak = false
    @State private var isShowingHeaderActionSheet = false
    @State private var selectedProgressCategory: ProgressCategory = .addition
    @State private var activeGameItem: GameItem? = nil

    private enum HeaderFocusItem: Hashable {
        case settings
        case progress
        case streak
        case profile
        case store
    }

    @FocusState private var headerFocus: HeaderFocusItem?

    init() {
        let args = ProcessInfo.processInfo.arguments
        if args.contains("-UITestOpenStreak") {
            _isShowingStreak = State(initialValue: true)
        } else if args.contains("-UITestOpenProgressFlags") {
            _selectedProgressCategory = State(initialValue: .flags)
            _isShowingProgressGrid = State(initialValue: true)
        } else if args.contains("-UITestOpenFlagsGame") {
            _activeGameItem = State(initialValue: GameItem(
                id: "15_1",
                gameType: .flags,
                level: .easy,
                requiredGoldStars: 0,
                requiredSilverStars: 0
            ))
        } else if args.contains("-UITestOpenElementsGame") {
            _activeGameItem = State(initialValue: GameItem(
                id: "14_1",
                gameType: .chemNames,
                level: .easy,
                requiredGoldStars: 0,
                requiredSilverStars: 0
            ))
        } else if args.contains("-UITestOpenMultiplicationGame") {
            _activeGameItem = State(initialValue: GameItem(
                id: "2_1",
                gameType: .multiplication,
                level: .easy,
                requiredGoldStars: 0,
                requiredSilverStars: 0
            ))
        }
    }

    var body: some View {
        ZStack {
            if let game = activeGameItem {
                GameView(
                    gameType: game.gameType,
                    level: game.level,
                    onDismiss: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            activeGameItem = nil
                        }
                    }
                )
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))
            } else {
                mainMenuContentView
            }
        }
        .onAppear {
            handleUITestLaunchArguments()
            #if os(tvOS)
            if headerFocus == nil {
                headerFocus = .settings
            }
            #endif
        }
    }

    private func handleUITestLaunchArguments() {
        let args = ProcessInfo.processInfo.arguments
        if args.contains("-UITestOpenStreak") {
            isShowingStreak = true
        } else if args.contains("-UITestOpenProgressFlags") {
            selectedProgressCategory = .flags
            isShowingProgressGrid = true
        } else if args.contains("-UITestOpenFlagsGame") {
            activeGameItem = GameItem(
                id: "15_1",
                gameType: .flags,
                level: .easy,
                requiredGoldStars: 0,
                requiredSilverStars: 0
            )
        } else if args.contains("-UITestOpenElementsGame") {
            activeGameItem = GameItem(
                id: "14_1",
                gameType: .chemNames,
                level: .easy,
                requiredGoldStars: 0,
                requiredSilverStars: 0
            )
        } else if args.contains("-UITestOpenMultiplicationGame") {
            activeGameItem = GameItem(
                id: "2_1",
                gameType: .multiplication,
                level: .easy,
                requiredGoldStars: 0,
                requiredSilverStars: 0
            )
        }
    }

    // MARK: - Main Menu Layout
    private var mainMenuContentView: some View {
        VStack(spacing: 0) {
            // App Navigation Header Bar
            appNavigationHeaderBar

            // Horizontal Level Selector Bar
            levelSelectorBar

            // Games List
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.filteredGames) { game in
                        GameRowView(
                            game: game,
                            isExpanded: viewModel.expandedGameId == game.id,
                            rawGoldStars: viewModel.totalGoldStars,
                            onTap: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    viewModel.toggleExpand(gameId: game.id)
                                }
                            },
                            onPlay: {
                                if game.isUnlocked {
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        activeGameItem = game
                                    }
                                } else if game.level >= .medium || game.level == .godlike || game.lockReason == .requiresPurchase {
                                    isShowingStore = true
                                }
                            },
                            onShowProgressGrid: {
                                selectedProgressCategory = categoryForGameType(game.gameType)
                                isShowingProgressGrid = true
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }

            // Global Footer Bar
            globalFooterBar
        }
        .background(FunColors.bgColor.ignoresSafeArea())
        .sheet(isPresented: $isShowingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $isShowingProgressGrid) {
            ProgressGridView(initialCategory: selectedProgressCategory)
        }
        .sheet(isPresented: $isShowingProfile) {
            ProfileView()
        }
        .sheet(isPresented: $isShowingStreak) {
            StreakView()
        }
        .sheet(isPresented: $isShowingStore) {
            StoreView()
                #if os(macOS)
                .frame(minWidth: 640, idealWidth: 700, minHeight: 700, idealHeight: 780)
                #elseif os(tvOS)
                .frame(minWidth: 1100, idealWidth: 1300, maxWidth: 1500, minHeight: 800, idealHeight: 900, maxHeight: 1000)
                #endif
        }
        .confirmationDialog(
            Text(LocalizedStringKey("nav_app_title")),
            isPresented: $isShowingHeaderActionSheet,
            titleVisibility: .visible
        ) {
            Button {
                isShowingProgressGrid = true
            } label: {
                Label(String(localized: "nav_progress"), systemImage: "book.fill")
            }

            Button {
                isShowingStreak = true
            } label: {
                Label(String(localized: "nav_streak"), systemImage: "calendar.badge.clock")
            }

            Button {
                isShowingProfile = true
            } label: {
                Label(String(localized: "nav_profile"), systemImage: "person.crop.circle.fill")
            }

            Button {
                isShowingStore = true
            } label: {
                Label(String(localized: "nav_store"), systemImage: "cart.fill")
            }

            Button(role: .cancel) {
            } label: {
                Text(LocalizedStringKey("dialog_cancel"))
            }
        }
    }

    // MARK: - App Navigation Header Bar
    private var appNavigationHeaderBar: some View {
        GeometryReader { proxy in
            let availableWidth = proxy.size.width
            #if os(tvOS)
            let hasSpaceForFullBar = true
            #else
            let hasSpaceForFullBar = availableWidth >= 580
            #endif

            HStack(spacing: 8) {
                // Left side: always settings (gear)
                Button(action: {
                    isShowingSettings = true
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
                .buttonStyle(FunHeaderButtonStyle())
                .focused($headerFocus, equals: .settings)

                if hasSpaceForFullBar {
                    Button(action: {
                        isShowingProgressGrid = true
                    }) {
                        Image(systemName: "book.fill")
                            .font(.title3)
                            .foregroundColor(.green)
                    }
                    .buttonStyle(FunHeaderButtonStyle())
                    .accessibilityIdentifier("btn_progress")
                    .focused($headerFocus, equals: .progress)
                }

                Spacer(minLength: 4)

                // Title: Always present and prioritized
                Text(LocalizedStringKey("nav_app_title"))
                    .font(.title2.bold())
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .layoutPriority(1)

                Spacer(minLength: 4)

                // Right side: All icons if space permits, otherwise single hamburger menu
                if hasSpaceForFullBar {
                    HStack(spacing: 10) {
                        Button(action: {
                            isShowingStreak = true
                        }) {
                            Image(systemName: "calendar.badge.clock")
                                .font(.title2)
                                .foregroundColor(.orange)
                        }
                        .buttonStyle(FunHeaderButtonStyle())
                        .accessibilityIdentifier("btn_streak")
                        .focused($headerFocus, equals: .streak)

                        Button(action: {
                            isShowingProfile = true
                        }) {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.title2)
                                .foregroundColor(.red)
                        }
                        .buttonStyle(FunHeaderButtonStyle())
                        .focused($headerFocus, equals: .profile)

                        Button(action: {
                            isShowingStore = true
                        }) {
                            Image(systemName: "cart.fill")
                                .font(.title3)
                                .foregroundColor(FunColors.chalkboardGreen)
                        }
                        .buttonStyle(FunHeaderButtonStyle())
                        .focused($headerFocus, equals: .store)
                    }
                } else {
                    #if os(iOS) || os(macOS)
                    Menu {
                        Button {
                            isShowingProgressGrid = true
                        } label: {
                            Label(String(localized: "nav_progress"), systemImage: "book.fill")
                        }

                        Button {
                            isShowingStreak = true
                        } label: {
                            Label(String(localized: "nav_streak"), systemImage: "calendar.badge.clock")
                        }

                        Button {
                            isShowingProfile = true
                        } label: {
                            Label(String(localized: "nav_profile"), systemImage: "person.crop.circle.fill")
                        }

                        Button {
                            isShowingStore = true
                        } label: {
                            Label(String(localized: "nav_store"), systemImage: "cart.fill")
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                            .padding(6)
                    }
                    .accessibilityIdentifier("btn_hamburger_menu")
                    #else
                    Button(action: {
                        isShowingHeaderActionSheet = true
                    }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                    }
                    .buttonStyle(FunHeaderButtonStyle())
                    .accessibilityIdentifier("btn_hamburger_menu")
                    #endif
                }
            }
            .padding(.horizontal, 20)
            .frame(width: availableWidth, height: proxy.size.height)
        }
        .frame(height: 52)
    }

    // MARK: - Level Selector Horizontal Bar
    private var levelSelectorBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(GameLevel.allCases) { lvl in
                    FilterChip(
                        title: lvl.title,
                        isSelected: viewModel.selectedLevel == lvl,
                        action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.selectedLevel = (viewModel.selectedLevel == lvl ? nil : lvl)
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
    }

    // MARK: - Global Footer Bar
    private var globalFooterBar: some View {
        ViewThatFits(in: .horizontal) {
            // 1. Full Footer (with text labels) when enough horizontal space exists
            footerContent(showLabels: true)

            // 2. Compact Footer (stars + number, total points only) when space is constrained
            footerContent(showLabels: false)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.gray.opacity(0.2)),
            alignment: .top
        )
    }

    @ViewBuilder
    private func footerContent(showLabels: Bool) -> some View {
        HStack(spacing: showLabels ? 16 : 12) {
            // Total Gold Stars
            HStack(spacing: 6) {
                Image(systemName: "star.circle.fill")
                    .font(.title2)
                    .foregroundColor(.yellow)

                if showLabels {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Text("\(viewModel.totalGoldStars)")
                                .font(.headline)
                                .foregroundColor(.primary)

                            if viewModel.isStarLimitReached {
                                Image(systemName: "lock.fill")
                                    .font(.caption.bold())
                                    .foregroundColor(.orange)
                            }
                        }
                        Text(LocalizedStringKey("footer_gold_stars"))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                } else {
                    HStack(spacing: 3) {
                        Text("\(viewModel.totalGoldStars)")
                            .font(.headline)
                            .foregroundColor(.primary)

                        if viewModel.isStarLimitReached {
                            Image(systemName: "lock.fill")
                                .font(.caption2.bold())
                                .foregroundColor(.orange)
                        }
                    }
                }
            }

            Spacer(minLength: 8)

            // Total Silver / Cumulative Stars
            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .font(.title2)
                    .foregroundColor(.gray)

                if showLabels {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(viewModel.totalSilverStars)")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(LocalizedStringKey("footer_silver_stars"))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text("\(viewModel.totalSilverStars)")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }

            Spacer(minLength: 8)

            // Total Score Counter
            if showLabels {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(viewModel.totalScore))")
                        .font(.title3.bold())
                        .foregroundColor(.blue)
                    Text(LocalizedStringKey("footer_total_score"))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "trophy.fill")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    Text("\(Int(viewModel.totalScore))")
                        .font(.headline.bold())
                        .foregroundColor(.blue)
                }
            }
        }
    }

    private func categoryForGameType(_ gameType: GameType) -> ProgressCategory {
        switch gameType {
        case .addition: return .addition
        case .subtraction: return .subtraction
        case .multiplication: return .multiplication
        case .division: return .division
        case .flags: return .flags
        case .capitals: return .capitals
        case .chemSymbols, .chemNames: return .elements
        default: return .addition
        }
    }
}

// MARK: - Filter Chip Component
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.bold())
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.secondary.opacity(0.12))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
        .buttonStyle(FunActionButtonStyle())
        .accessibilityIdentifier("filter_chip_\(title)")
    }
}



// MARK: - Helper Status Pill
struct StatusPill: View {
    let title: String
    let value: String
    let color: Color
    let iconName: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: iconName)
                .font(.caption)
                .foregroundColor(color)

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.secondary)

                Text(value)
                    .font(.caption.bold())
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.12))
        .cornerRadius(8)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Compact Phone preview (Hamburger menu & compact footer)
            ContentView()
                .previewDisplayName("Compact iPhone (Hamburger & Compact Footer)")
                .previewLayout(.fixed(width: 393, height: 852))

            // Wide iPad/Mac preview (Full bar & labeled footer)
            ContentView()
                .previewDisplayName("Wide Screen (Full Bar & Labeled Footer)")
                .previewLayout(.fixed(width: 820, height: 1180))
        }
    }
}

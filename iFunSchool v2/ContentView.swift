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
            // In compact widths, right icons would encroach on the title.
            // On iPhone portrait (width ~375-430pt), collapse right icons to a hamburger icon
            // so the title is never squeezed or truncated.
            let hasSpaceForFullBar = availableWidth >= 580

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

                        Button(action: {
                            isShowingProfile = true
                        }) {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.title2)
                                .foregroundColor(.red)
                        }
                        .buttonStyle(FunHeaderButtonStyle())

                        Button(action: {
                            isShowingStore = true
                        }) {
                            Image(systemName: "cart.fill")
                                .font(.title3)
                                .foregroundColor(FunColors.chalkboardGreen)
                        }
                        .buttonStyle(FunHeaderButtonStyle())
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

// MARK: - Game Row Card Component
struct GameRowView: View {
    let game: GameItem
    let isExpanded: Bool
    let rawGoldStars: Int
    let onTap: () -> Void
    let onPlay: () -> Void
    var onShowProgressGrid: (() -> Void)? = nil

    @StateObject private var storeKitService = StoreKitService.shared
    @State private var progressRefreshTrigger: Bool = false

    // Progress Computation Helpers
    private var hasProgressTracking: Bool {
        !levelItemKeys.isEmpty
    }

    private var levelItemKeys: [String] {
        _ = progressRefreshTrigger
        return QuestionGenerator.shared.itemKeysForLevel(gameType: game.gameType, level: game.level)
    }

    private var progressTotalCount: Int {
        levelItemKeys.count
    }

    private var progressCorrectCount: Int {
        guard !levelItemKeys.isEmpty else { return 0 }
        let dict = ItemProgressTracker.shared.getProgressDict()
        return levelItemKeys.filter { key in
            dict[key]?.status == .correct
        }.count
    }

    private var progressWrongCount: Int {
        guard !levelItemKeys.isEmpty else { return 0 }
        let dict = ItemProgressTracker.shared.getProgressDict()
        return levelItemKeys.filter { key in
            dict[key]?.status == .incorrect
        }.count
    }

    private var progressUnaskedCount: Int {
        max(0, progressTotalCount - (progressCorrectCount + progressWrongCount))
    }

    private var progressSummaryText: String {
        let label = NSLocalizedString("progress_summary_total", comment: "Mastered")
        return "\(label): \(progressCorrectCount) / \(progressTotalCount) (\(progressPercent)%)"
    }

    private var progressPercent: Int {
        guard progressTotalCount > 0 else { return 0 }
        return Int((Double(progressCorrectCount) / Double(progressTotalCount)) * 100.0)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header Row (Entire Row is Clickable)
            Button(action: onTap) {
                HStack(spacing: 14) {
                    // Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(iconBackgroundColor)
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: game.gameType.systemIcon)
                            .font(.title2)
                            .foregroundColor(game.isUnlocked ? .white : .gray)
                    }

                    // Title & Level
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text(game.gameType.title)
                                .font(.headline)
                                .foregroundColor(game.isUnlocked ? .primary : .secondary)

                            if !game.isUnlocked {
                                Image(systemName: "lock.fill")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }

                        Text(game.level.title)
                            .font(.caption.bold())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(game.level == .godlike ? Color.black : levelBadgeColor.opacity(0.15))
                            .foregroundColor(game.level == .godlike ? Color.white : levelBadgeColor)
                            .cornerRadius(6)
                    }

                    Spacer()

                    // Quick Stars / Status Summary
                    HStack(spacing: 4) {
                        if game.levelStars > 0 {
                            HStack(spacing: 3) {
                                ForEach(1...4, id: \.self) { starIndex in
                                    Image(systemName: starIndex <= game.levelStars ? "star.fill" : "star")
                                        .font(.caption2)
                                        .foregroundColor(starIndex <= game.levelStars ? .gray : .gray.opacity(0.3))
                                }

                                Image(systemName: game.levelStars == 5 ? "star.circle.fill" : "star.circle")
                                    .font(.subheadline)
                                    .foregroundColor(game.levelStars == 5 ? .yellow : .yellow.opacity(0.4))
                            }
                        } else if game.isUnlocked {
                            Text(LocalizedStringKey("badge_new"))
                                .font(.caption2.bold())
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green.opacity(0.2))
                                .foregroundColor(.green)
                                .cornerRadius(4)
                        } else {
                            Text(LocalizedStringKey("badge_locked"))
                                .font(.caption2.bold())
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.red.opacity(0.15))
                                .foregroundColor(.red)
                                .cornerRadius(4)
                        }

                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                            .padding(.leading, 4)
                    }
                }
                .padding(14)
                .contentShape(Rectangle()) // Makes entire row clickable including empty spaces
            }
            .buttonStyle(FunRowButtonStyle())

            // Expanded Details Section
            if isExpanded {
                Divider()
                    .padding(.horizontal, 14)

                VStack(alignment: .leading, spacing: 12) {
                    if game.isUnlocked {
                        // Played Status Summary
                        HStack(spacing: 12) {
                            StatusPill(
                                title: NSLocalizedString("status_title", comment: "Status"),
                                value: game.gameStatus.title,
                                color: statusColor,
                                iconName: statusIcon
                            )

                            if game.levelStars > 0 {
                                StatusPill(
                                    title: NSLocalizedString("highscore_title", comment: "High Score"),
                                    value: "\(game.highScore) pts",
                                    color: .blue,
                                    iconName: "trophy.fill"
                                )
                            }
                        }

                        // Learning Progress Card for Flags & Chemistry Games
                        if hasProgressTracking {
                            HStack {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(progressSummaryText)
                                        .font(.subheadline.bold())
                                        .foregroundColor(.primary)
                                    HStack(spacing: 8) {
                                        Text("🟢 \(progressCorrectCount)")
                                            .font(.caption)
                                        Text("🔴 \(progressWrongCount)")
                                            .font(.caption)
                                        Text("⚪ \(progressUnaskedCount)")
                                            .font(.caption)
                                    }
                                }
                                Spacer()
                                Button(action: {
                                    onShowProgressGrid?()
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "book.fill")
                                        Text(LocalizedStringKey("nav_progress"))
                                            .font(.caption.bold())
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.green.opacity(0.15))
                                    .foregroundColor(.green)
                                    .cornerRadius(8)
                                }
                                .buttonStyle(FunRowButtonStyle())
                            }
                            .padding(10)
                            .background(Color.secondary.opacity(0.08))
                            .cornerRadius(10)
                        }

                        // Play Button
                        Button(action: onPlay) {
                            HStack {
                                Spacer()
                                Label(game.levelStars > 0 ? NSLocalizedString("btn_play_again", comment: "Play Again") : NSLocalizedString("btn_start_game", comment: "Start Game"), systemImage: "play.fill")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                        .buttonStyle(FunActionButtonStyle())
                        .accessibilityIdentifier("btn_start_game")
                    } else {
                        // Locked Info Section
                        HStack(spacing: 12) {
                            Image(systemName: "lock.circle.fill")
                                .font(.title)
                                .foregroundColor(.red)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(lockReasonTitle)
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                if game.level != .godlike {
                                    HStack(spacing: 4) {
                                        Text(LocalizedStringKey("req_stars_prefix"))
                                        
                                        if game.requiredGoldStars > 0 {
                                            Image(systemName: "star.circle.fill")
                                                .foregroundColor(.yellow)
                                                .font(.caption)
                                            Text("\(game.requiredGoldStars)")
                                        }
                                    }
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                }
                            }

                            Spacer()

                            if (game.level >= .medium || game.level == .godlike) && (game.lockReason == .requiresPurchase || game.lockReason == .requiresSubscription || game.lockReason == .godlikeLocked) {
                                Button(action: onPlay) {
                                    Text(LocalizedStringKey("btn_buy"))
                                        .font(.subheadline.bold())
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(FunColors.chalkboardGreen)
                                        .cornerRadius(10)
                                }
                                .buttonStyle(FunActionButtonStyle())
                            }
                        }
                    }
                }
                .padding(14)
                .background(Color.secondary.opacity(0.05))
            }
        }
        .background(Color.secondary.opacity(0.06))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("iFunSchoolItemProgressUpdated"))) { _ in
            progressRefreshTrigger.toggle()
        }
    }

    private var iconBackgroundColor: Color {
        switch game.gameType {
        case .addition, .subtraction, .multiplication, .division, .order, .sequences, .equations:
            return .blue
        case .memoryAdd, .memoryAddSub, .memoryAddSubMult, .memoryShapes, .memoryColors:
            return .purple
        case .chemSymbols, .chemNames:
            return .green
        case .flags:
            return .orange
        }
    }

    private var levelBadgeColor: Color {
        switch game.level {
        case .beginner: return .green
        case .easy: return .blue
        case .medium: return .orange
        case .hard: return .purple
        case .ultimate: return .red
        case .godlike: return .black
        }
    }

    private var statusColor: Color {
        switch game.gameStatus {
        case .perfect: return .green
        case .standard: return .blue
        case .unplayed: return .gray
        case .locked: return .red
        }
    }

    private var statusIcon: String {
        switch game.gameStatus {
        case .perfect: return "star.circle.fill"
        case .standard: return "play.circle.fill"
        case .unplayed: return "circle"
        case .locked: return "lock.fill"
        }
    }

    private var lockReasonTitle: String {
        if game.lockReason == .requiresPurchase || game.lockReason == .requiresSubscription || game.lockReason == .godlikeLocked {
            return NSLocalizedString("lock_reason_godlike_title", comment: "Purchase Required")
        }
        return NSLocalizedString("lock_stars_req_title", comment: "Stars Required")
    }

    private var lockReasonMessage: String {
        if game.level == .godlike && (game.lockReason == .requiresPurchase || game.lockReason == .godlikeLocked) {
            return NSLocalizedString("lock_reason_godlike", comment: "Unlock Master level in Shop")
        } else if game.lockReason == .requiresPurchase || game.lockReason == .requiresSubscription {
            return NSLocalizedString("lock_reason_requires_purchase_msg", comment: "Unlock in Shop to play this level")
        }
        
        if game.requiredGoldStars > 0 {
            let formatStr = NSLocalizedString("lock_stars_req_msg", comment: "Collect stars to unlock")
            return String(format: formatStr, game.requiredGoldStars)
        } else {
            return ""
        }
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

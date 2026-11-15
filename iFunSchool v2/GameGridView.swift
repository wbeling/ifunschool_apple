//
//  GameGridView.swift
//  iFunSchool
//
//  Created by Wojciech Beling on 14/11/2026.
//  Copyright © 2026 Beling.pl. All rights reserved.
//

import SwiftUI

struct GameGridView: View {
    let groups: [GameGroup]
    let expandedGameType: GameType?
    let totalGoldStars: Int
    @Binding var scrollToGameType: GameType?
    let onToggleExpand: (GameType) -> Void
    let onPlay: (GameItem) -> Void
    let onOpenStore: () -> Void
    let onShowProgressGrid: (ProgressCategory) -> Void

    #if os(tvOS)
    @FocusState private var focusedTileType: GameType?
    #endif
    @FocusState private var focusedExpandedItemId: String?

    private var horizontalPadding: CGFloat {
        #if os(tvOS)
        return 36
        #else
        return 16
        #endif
    }

    private var colSpacing: CGFloat {
        #if os(tvOS)
        return 20
        #else
        return 12
        #endif
    }

    private var rowSpacing: CGFloat {
        #if os(tvOS)
        return 24
        #else
        return 14
        #endif
    }

    var body: some View {
        GeometryReader { proxy in
            let colCount = columnCount(for: proxy.size.width)
            let rows = chunkedGroups(groups, size: colCount)

            ScrollViewReader { scrollProxy in
                ScrollView {
                    LazyVStack(spacing: rowSpacing) {
                        ForEach(Array(rows.enumerated()), id: \.offset) { rowIndex, rowGroups in
                            VStack(spacing: 12) {
                                HStack(alignment: .top, spacing: colSpacing) {
                                    ForEach(rowGroups) { group in
                                        GameGridTileView(
                                            group: group,
                                            isExpanded: expandedGameType == group.gameType,
                                            onTap: {
                                                withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                                    onToggleExpand(group.gameType)
                                                }
                                            }
                                        )
                                        .frame(maxWidth: .infinity)
                                        .id("grid_tile_\(group.gameType.rawValue)")
                                        #if os(tvOS)
                                        .focused($focusedTileType, equals: group.gameType)
                                        #endif
                                    }

                                    // Pad incomplete last row so all grid cells share equal width
                                    if rowGroups.count < colCount {
                                        ForEach(0..<(colCount - rowGroups.count), id: \.self) { _ in
                                            Color.clear
                                                .frame(maxWidth: .infinity)
                                        }
                                    }
                                }

                                if let expandedGroup = rowGroups.first(where: { $0.gameType == expandedGameType }) {
                                    GameGridExpandedDetailView(
                                        group: expandedGroup,
                                        totalGoldStars: totalGoldStars,
                                        focusedExpandedItemId: $focusedExpandedItemId,
                                        onClose: {
                                            #if os(tvOS)
                                            let closingType = expandedGroup.gameType
                                            #endif
                                            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                                onToggleExpand(expandedGroup.gameType)
                                            }
                                            #if os(tvOS)
                                            DispatchQueue.main.async {
                                                focusedTileType = closingType
                                            }
                                            #endif
                                        },
                                        onPlay: onPlay,
                                        onOpenStore: onOpenStore,
                                        onShowProgressGrid: onShowProgressGrid
                                    )
                                    .id("grid_expanded_\(expandedGroup.gameType.rawValue)")
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                                }
                            }
                            .id("grid_row_\(rowIndex)")
                        }
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }
                .onChange(of: expandedGameType) { _, newType in
                    guard let newType = newType else { return }
                    #if os(tvOS)
                    let firstItemId = groups
                        .first(where: { $0.gameType == newType })?
                        .levels
                        .first(where: { $0.hasGridActionButton })?
                        .id
                    #endif
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            scrollProxy.scrollTo("grid_expanded_\(newType.rawValue)", anchor: .center)
                        }
                        #if os(tvOS)
                        if let firstItemId = firstItemId, expandedGameType == newType {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                if expandedGameType == newType {
                                    focusedExpandedItemId = firstItemId
                                }
                            }
                        }
                        #endif
                    }
                }
                .onChange(of: scrollToGameType) { _, targetType in
                    guard let targetType = targetType else { return }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            scrollProxy.scrollTo("grid_expanded_\(targetType.rawValue)", anchor: .center)
                        }
                        scrollToGameType = nil
                    }
                }
            }
        }
    }

    private func columnCount(for totalWidth: CGFloat) -> Int {
        let availableWidth = max(totalWidth - (horizontalPadding * 2), 200)
        #if os(tvOS)
        let minTileWidth: CGFloat = 240
        let rawCount = Int((availableWidth + colSpacing) / (minTileWidth + colSpacing))
        return min(max(rawCount, 4), 6)
        #else
        if totalWidth < 550 {
            let minTileWidth: CGFloat = 98
            let rawCount = Int((availableWidth + colSpacing) / (minTileWidth + colSpacing))
            return min(max(rawCount, 3), 4)
        } else {
            let minTileWidth: CGFloat = 145
            let rawCount = Int((availableWidth + colSpacing) / (minTileWidth + colSpacing))
            return min(max(rawCount, 4), 6)
        }
        #endif
    }

    private func chunkedGroups(_ array: [GameGroup], size: Int) -> [[GameGroup]] {
        guard size > 0 else { return [array] }
        return stride(from: 0, to: array.count, by: size).map {
            Array(array[$0..<min($0 + size, array.count)])
        }
    }
}

// MARK: - Grid Icon Tile
struct GameGridTileView: View {
    let group: GameGroup
    let isExpanded: Bool
    let onTap: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    private var displayBadgeLevel: GameLevel {
        if group.highestStarUnlockedLevel == .ultimate && group.isGodlikeUnlocked {
            return .godlike
        }
        return group.highestStarUnlockedLevel
    }

    private var iconSize: CGFloat {
        #if os(tvOS)
        return 84
        #else
        return 52
        #endif
    }

    private var iconCornerRadius: CGFloat {
        #if os(tvOS)
        return 20
        #else
        return 14
        #endif
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // Game Icon + optional Godlike Crown indicator
                ZStack(alignment: .topTrailing) {
                    ZStack {
                        RoundedRectangle(cornerRadius: iconCornerRadius)
                            .fill(group.gameType.categoryColor.gradient)
                            .frame(width: iconSize, height: iconSize)

                        Image(systemName: group.gameType.systemIcon)
                            .font(iconSymbolFont)
                            .foregroundColor(.white)
                    }

                    if group.isGodlikeUnlocked {
                        Image(systemName: "crown.fill")
                            .font(.system(size: godlikeBadgeIconSize, weight: .bold))
                            .foregroundColor(.yellow)
                            .padding(godlikeBadgePadding)
                            .background(Circle().fill(Color.black))
                            .overlay(Circle().stroke(Color.yellow.opacity(0.8), lineWidth: 1))
                            .offset(x: 6, y: -6)
                    }
                }
                .padding(.top, 2)

                // Game Title
                Text(group.gameType.title)
                    .font(titleFont)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
                    .frame(height: titleHeight, alignment: .center)

                // Highest Unlocked Level Badge
                Text(displayBadgeLevel.title)
                    .font(badgeFont)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(badgeBackgroundColor(for: displayBadgeLevel))
                    .foregroundColor(badgeForegroundColor(for: displayBadgeLevel))
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(displayBadgeLevel == .godlike && colorScheme == .dark ? Color.yellow.opacity(0.6) : Color.clear, lineWidth: 1)
                    )

                // 6-Segment Mini Difficulty Indicator
                HStack(spacing: 3) {
                    ForEach(group.levels) { item in
                        segmentView(for: item)
                    }
                }
                .padding(.horizontal, 4)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(
            FunGridTileButtonStyle(
                isSelected: isExpanded,
                accentColor: group.gameType.categoryColor
            )
        )
        .accessibilityIdentifier("grid_tile_\(group.gameType.rawValue)")
    }

    @ViewBuilder
    private func segmentView(for item: GameItem) -> some View {
        let segmentHeight: CGFloat = {
            #if os(tvOS)
            return 7
            #else
            return 5
            #endif
        }()

        let baseColor: Color = {
            if item.level == .godlike {
                return colorScheme == .dark ? Color.yellow : Color.black
            }
            return item.level.badgeColor
        }()

        switch item.gameStatus {
        case .locked:
            Capsule()
                .fill(Color.gray.opacity(0.22))
                .frame(height: segmentHeight)
        case .unplayed:
            Capsule()
                .fill(baseColor.opacity(0.25))
                .overlay(
                    Capsule()
                        .stroke(baseColor.opacity(0.85), lineWidth: 1)
                )
                .frame(height: segmentHeight)
        case .standard:
            Capsule()
                .fill(baseColor.opacity(0.85))
                .frame(height: segmentHeight)
        case .perfect:
            Capsule()
                .fill(baseColor)
                .overlay(
                    Capsule()
                        .stroke(Color.yellow.opacity(item.level == .godlike ? 0.9 : 0.7), lineWidth: 1)
                )
                .frame(height: segmentHeight)
        }
    }

    private var iconSymbolFont: Font {
        #if os(tvOS)
        return .title
        #else
        return .title2
        #endif
    }

    private var godlikeBadgeIconSize: CGFloat {
        #if os(tvOS)
        return 14
        #else
        return 9
        #endif
    }

    private var godlikeBadgePadding: CGFloat {
        #if os(tvOS)
        return 6
        #else
        return 4
        #endif
    }

    private var titleFont: Font {
        #if os(tvOS)
        return .headline
        #else
        return .caption.bold()
        #endif
    }

    private var titleHeight: CGFloat {
        #if os(tvOS)
        return 56
        #else
        return 34
        #endif
    }

    private var badgeFont: Font {
        #if os(tvOS)
        return .caption.bold()
        #else
        return .caption2.bold()
        #endif
    }

    private func badgeBackgroundColor(for level: GameLevel) -> Color {
        if level == .godlike {
            return colorScheme == .dark ? Color(white: 0.18) : Color.black
        }
        return level.badgeColor.opacity(0.16)
    }

    private func badgeForegroundColor(for level: GameLevel) -> Color {
        if level == .godlike {
            return .white
        }
        return level.badgeColor
    }
}

// MARK: - Inline Expanded Detail Panel (All 6 Difficulties)
struct GameGridExpandedDetailView: View {
    let group: GameGroup
    let totalGoldStars: Int
    var focusedExpandedItemId: FocusState<String?>.Binding
    let onClose: () -> Void
    let onPlay: (GameItem) -> Void
    let onOpenStore: () -> Void
    let onShowProgressGrid: (ProgressCategory) -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Detail Header
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(group.gameType.categoryColor.gradient)
                        .frame(width: headerIconSize, height: headerIconSize)

                    Image(systemName: group.gameType.systemIcon)
                        .font(.headline)
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(group.gameType.title)
                        .font(.headline.bold())
                        .foregroundColor(.primary)

                    let unlockedCount = group.levels.filter { $0.isUnlocked }.count
                    Text("\(unlockedCount) / \(group.levels.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if let progressCat = group.gameType.progressCategory {
                    Button(action: {
                        onShowProgressGrid(progressCat)
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
                    .buttonStyle(FunActionButtonStyle(cornerRadius: 8))
                }

                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(FunHeaderButtonStyle())
            }

            Divider()

            // Sublist of all 6 Difficulties
            VStack(spacing: 8) {
                ForEach(group.levels) { item in
                    GameGridDifficultyRow(
                        item: item,
                        totalGoldStars: totalGoldStars,
                        focusedExpandedItemId: focusedExpandedItemId,
                        onPlay: { onPlay(item) },
                        onOpenStore: onOpenStore
                    )
                }
            }
        }
        .padding(14)
        .background(FunColors.bgColor2)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(group.gameType.categoryColor.opacity(0.35), lineWidth: 1.5)
        )
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.35 : 0.08), radius: 8, y: 3)
        #if os(tvOS)
        .focusSection()
        #endif
        .accessibilityIdentifier("grid_expanded_detail_\(group.gameType.rawValue)")
    }

    private var headerIconSize: CGFloat {
        #if os(tvOS)
        return 48
        #else
        return 36
        #endif
    }
}

// MARK: - Difficulty Row Inside Expanded Card
private struct GameGridDifficultyRow: View {
    let item: GameItem
    let totalGoldStars: Int
    var focusedExpandedItemId: FocusState<String?>.Binding
    let onPlay: () -> Void
    let onOpenStore: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 12) {
            // Difficulty Badge
            Text(item.level.title)
                .font(.caption.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .frame(minWidth: badgeMinWidth)
                .background(levelBadgeBackground)
                .foregroundColor(item.level == .godlike ? .white : item.level.badgeColor)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(item.level == .godlike && colorScheme == .dark ? Color.yellow.opacity(0.5) : Color.clear, lineWidth: 1)
                )

            // Status / Stars / Lock Reason
            if item.isUnlocked {
                VStack(alignment: .leading, spacing: 3) {
                    if item.levelStars > 0 {
                        HStack(spacing: 3) {
                            ForEach(1...4, id: \.self) { starIndex in
                                Image(systemName: starIndex <= item.levelStars ? "star.fill" : "star")
                                    .font(.caption2)
                                    .foregroundColor(starIndex <= item.levelStars ? .gray : .gray.opacity(0.3))
                            }

                            Image(systemName: item.levelStars == 5 ? "star.circle.fill" : "star.circle")
                                .font(.subheadline)
                                .foregroundColor(item.levelStars == 5 ? .yellow : .yellow.opacity(0.4))
                        }

                        Text("\(item.highScore) pts")
                            .font(.caption2.bold())
                            .foregroundColor(.blue)
                    } else {
                        Text(LocalizedStringKey("badge_new"))
                            .font(.caption2.bold())
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .cornerRadius(4)
                    }
                }
            } else {
                HStack(spacing: 6) {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundColor(.red)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(lockReasonDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)

                        if item.level != .godlike && item.requiredGoldStars > 0 {
                            Text("\(totalGoldStars) / \(item.requiredGoldStars)")
                                .font(.caption2.bold())
                                .foregroundColor(.orange)
                        }
                    }
                }
            }

            Spacer(minLength: 8)

            // Action Button (Play or Unlock in Shop)
            if item.isUnlocked {
                Button(action: onPlay) {
                    HStack(spacing: 5) {
                        Image(systemName: "play.fill")
                            .font(.caption)
                        Text(item.levelStars > 0 ? LocalizedStringKey("btn_play_again") : LocalizedStringKey("btn_start_game"))
                            .font(.caption.bold())
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .buttonStyle(FunActionButtonStyle(cornerRadius: 10))
                .focused(focusedExpandedItemId, equals: item.id)
                .accessibilityIdentifier("btn_start_game_\(item.id)")
            } else if isPurchaseGated {
                Button(action: onOpenStore) {
                    HStack(spacing: 5) {
                        Image(systemName: "cart.fill")
                            .font(.caption)
                        Text(LocalizedStringKey("btn_buy"))
                            .font(.caption.bold())
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(FunColors.chalkboardGreen)
                    .cornerRadius(10)
                }
                .buttonStyle(FunActionButtonStyle(cornerRadius: 10))
                .focused(focusedExpandedItemId, equals: item.id)
            } else {
                Text(LocalizedStringKey("badge_locked"))
                    .font(.caption2.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red.opacity(0.12))
                    .foregroundColor(.red)
                    .cornerRadius(6)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color.secondary.opacity(0.06))
        .cornerRadius(12)
    }

    private var badgeMinWidth: CGFloat {
        #if os(tvOS)
        return 130
        #else
        return 82
        #endif
    }

    private var levelBadgeBackground: Color {
        if item.level == .godlike {
            return colorScheme == .dark ? Color(white: 0.18) : Color.black
        }
        return item.level.badgeColor.opacity(0.16)
    }

    private var isPurchaseGated: Bool {
        item.isGridPurchaseGated
    }

    private var lockReasonDescription: String {
        if item.level == .godlike && (item.lockReason == .requiresPurchase || item.lockReason == .godlikeLocked) {
            return NSLocalizedString("lock_reason_godlike", comment: "Unlock Godlike difficulty in Shop")
        } else if item.lockReason == .requiresPurchase || item.lockReason == .requiresSubscription {
            return NSLocalizedString("lock_reason_requires_purchase_msg", comment: "Unlock star limit in Shop")
        } else if item.requiredGoldStars > 0 {
            let formatStr = NSLocalizedString("lock_stars_req_msg", comment: "Requires %d stars")
            return String(format: formatStr, item.requiredGoldStars)
        } else {
            return NSLocalizedString("lock_reason_not_enough_stars", comment: "Collect more stars")
        }
    }
}

private extension GameItem {
    var isGridPurchaseGated: Bool {
        (level >= .medium || level == .godlike) &&
        (lockReason == .requiresPurchase || lockReason == .requiresSubscription || lockReason == .godlikeLocked)
    }

    var hasGridActionButton: Bool {
        isUnlocked || isGridPurchaseGated
    }
}

#Preview("GameGridView") {
    let sampleViewModel = GameListViewModel()
    return GameGridView(
        groups: sampleViewModel.gameGroups,
        expandedGameType: .addition,
        totalGoldStars: sampleViewModel.totalGoldStars,
        scrollToGameType: .constant(nil),
        onToggleExpand: { _ in },
        onPlay: { _ in },
        onOpenStore: {},
        onShowProgressGrid: { _ in }
    )
    .background(FunColors.bgColor)
}

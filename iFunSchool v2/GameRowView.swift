//
//  GameRowView.swift
//  iFunSchool
//
//  Created by Wojciech Beling on 23/10/2026.
//  Copyright © 2026 Beling.pl. All rights reserved.
//

import SwiftUI
import StoreKit

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
                        RoundedRectangle(cornerRadius: iconCornerRadius)
                            .fill(iconBackgroundColor)
                            .frame(width: iconSize, height: iconSize)
                        
                        Image(systemName: game.gameType.systemIcon)
                            .font(.title2)
                            .foregroundColor(.white) // always white, even if locaked (old value for !game.isUnlocked was .gray)
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

                        HStack(spacing: 0) {
                            
                            Text(game.level.title)
                                .font(.caption.bold())
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(game.level == .godlike ? Color.black : levelBadgeColor.opacity(0.15))
                                .foregroundColor(game.level == .godlike ? Color.white : levelBadgeColor)
                                .cornerRadius(6)
                         
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

    private var iconCornerRadius: CGFloat {
        return 12
    }
    
    private var iconSize: CGFloat {
        #if os(tvOS)
        return 96
        #else
        return 48
        #endif
    }

    private var iconBackgroundColor: Color {
        switch game.gameType {
        case .addition, .subtraction, .multiplication, .division, .order, .sequences, .equations:
            return .blue
        case .memoryAdd, .memoryAddSub, .memoryAddSubMult, .memoryShapes, .memoryColors:
            return .purple
        case .chemSymbols, .chemNames:
            return .green
        case .flags, .capitals:
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
// MARK: - Previews

#Preview("Collapsed") {
    GameRowView(
        game: GameItem(
            id: "1_1",
            gameType: .addition,
            level: .easy,
            requiredGoldStars: 0,
            requiredSilverStars: 0,
            status: .standard,
            topScore: 150,
            topTime: 45,
            topStars: 3
        ),
        isExpanded: false,
        rawGoldStars: 10,
        onTap: {},
        onPlay: {}
    )
    .padding()
}

#Preview("Expanded") {
    GameRowView(
        game: GameItem(
            id: "15_2",
            gameType: .flags,
            level: .medium,
            requiredGoldStars: 0,
            requiredSilverStars: 0,
            status: .perfect,
            topScore: 300,
            topTime: 25,
            topStars: 5
        ),
        isExpanded: true,
        rawGoldStars: 20,
        onTap: {},
        onPlay: {},
        onShowProgressGrid: {}
    )
    .padding()
}

#Preview("Locked") {
    GameRowView(
        game: GameItem(
            id: "1_5",
            gameType: .addition,
            level: .godlike,
            requiredGoldStars: 15,
            requiredSilverStars: 0,
            status: .locked,
            lockReason: .godlikeLocked
        ),
        isExpanded: true,
        rawGoldStars: 5,
        onTap: {},
        onPlay: {}
    )
    .padding()
}


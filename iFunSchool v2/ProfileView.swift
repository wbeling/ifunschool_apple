import SwiftUI
import GameKit

struct ProfileView: View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var profileManager = ProfileManager.shared
    private let scoreStorage = ScoreStorage.shared

    @State private var selectedLeaderboardID: String? = nil
    @State private var isShowingLeaderboard: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            HStack {
                Text(LocalizedStringKey("nav_profile"))
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
            .padding(.horizontal, 24)
            .padding(.vertical, 16)

            Divider()

            ScrollView {
                VStack(spacing: 20) {
                    // Active Profile Card
                    activeProfileCard

                    // Available Profiles Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text(LocalizedStringKey("profile_select_header"))
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)

                        ForEach(profileManager.availableProfiles) { profile in
                            profileOptionRow(profile: profile)
                        }
                    }

                    // Informational Footer Notice
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                        Text(LocalizedStringKey("profile_switch_notice"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(12)
                    .background(Color.blue.opacity(0.08))
                    .cornerRadius(10)
                }
                .padding(24)
            }
        }
        .background(FunColors.bgColor.ignoresSafeArea())
        .sheet(isPresented: $isShowingLeaderboard) {
            GameCenterView(state: .leaderboards, leaderboardID: selectedLeaderboardID)
        }
        #if os(macOS)
        .frame(minWidth: 500, idealWidth: 600, minHeight: 450, idealHeight: 550)
        #elseif os(tvOS)
        .frame(minWidth: 900, idealWidth: 1000, minHeight: 650, idealHeight: 750)
        #endif
    }

    private var activeProfileCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(profileManager.activeProfile.isGameCenter ? Color.blue : Color.orange)
                        .frame(width: 56, height: 56)

                    Image(systemName: profileManager.activeProfile.isGameCenter ? "gamecontroller.fill" : "person.fill")
                        .font(.title)
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(LocalizedStringKey("profile_active_label"))
                        .font(.caption.bold())
                        .foregroundColor(.secondary)

                    Text(profileManager.activeProfile.displayName)
                        .font(.title3.bold())
                        .foregroundColor(.primary)

                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "star.circle.fill")
                                .foregroundColor(.yellow)
                            Text("\(scoreStorage.totalGoldStars)")
                                .font(.subheadline.bold())
                        }

                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.gray)
                            Text("\(scoreStorage.totalSilverStars)")
                                .font(.subheadline.bold())
                        }
                    }
                }

                Spacer()
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text(LocalizedStringKey("profile_scores_by_level"))
                    .font(.caption.bold())
                    .foregroundColor(.secondary)

                VStack(spacing: 6) {
                    ForEach(GameLevel.allCases) { level in
                        let pts = Int(scoreStorage.totalScore(for: level))
                        let leaderID = "pl.beling.ifunschool.totalLvl\(level.rawValue)"

                        HStack {
                            Text(level.title)
                                .font(.caption.bold())
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(level == .godlike ? Color.black : level.badgeColor.opacity(0.15))
                                .foregroundColor(level == .godlike ? Color.white : level.badgeColor)
                                .cornerRadius(6)

                            Spacer()

                            Button(action: {
                                selectedLeaderboardID = leaderID
                                isShowingLeaderboard = true
                            }) {
                                HStack(spacing: 4) {
                                    Text("\(pts) pts")
                                        .font(.subheadline.bold())
                                        .foregroundColor(.primary)

                                    Image(systemName: "list.number")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.08))
                                .cornerRadius(8)
                            }
                            .buttonStyle(FunActionButtonStyle())
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(16)
    }

    private func profileOptionRow(profile: PlayerProfile) -> some View {
        let isSelected = profile.id == profileManager.activeProfile.id

        return Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                profileManager.selectProfile(profile)
            }
        }) {
            HStack(spacing: 14) {
                Image(systemName: profile.isGameCenter ? "gamecontroller.fill" : "person.fill")
                    .font(.title2)
                    .foregroundColor(profile.isGameCenter ? .blue : .orange)
                    .frame(width: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text(profile.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(profile.isGameCenter ? LocalizedStringKey("profile_gc_signed_in") : LocalizedStringKey("profile_local_user"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                }
            }
            .padding(14)
            .background(isSelected ? Color.green.opacity(0.1) : Color.secondary.opacity(0.06))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.green.opacity(0.4) : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(FunActionButtonStyle())
    }
}

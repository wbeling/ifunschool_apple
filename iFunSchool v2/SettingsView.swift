import SwiftUI
import GameKit

enum GameCenterSheetType: Identifiable {
    case achievements
    case leaderboards

    var id: String {
        switch self {
        case .achievements: return "achievements"
        case .leaderboards: return "leaderboards"
        }
    }

    var gcState: GKGameCenterViewControllerState {
        switch self {
        case .achievements: return .achievements
        case .leaderboards: return .leaderboards
        }
    }
}

// MARK: - Reusable Settings Card Section for macOS and tvOS
struct SettingsCardSection<Content: View>: View {
    let titleKey: String
    let iconName: String
    let iconColor: Color
    let footerKey: String?
    let content: Content

    init(titleKey: String, iconName: String, iconColor: Color, footerKey: String? = nil, @ViewBuilder content: () -> Content) {
        self.titleKey = titleKey
        self.iconName = iconName
        self.iconColor = iconColor
        self.footerKey = footerKey
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Section Header
            HStack(spacing: 8) {
                Image(systemName: iconName)
                    .font(.headline)
                    .foregroundColor(iconColor)
                Text(LocalizedStringKey(titleKey))
                    .font(.headline.bold())
                    .foregroundColor(.primary)
            }
            .padding(.leading, 6)

            // Card Container
            VStack(spacing: 0) {
                content
            }
            #if os(macOS)
            .background(Color(NSColor.controlBackgroundColor))
            #elseif os(tvOS)
            .background(Color.white.opacity(0.12))
            #else
            .background(FunColors.bgColor2)
            #endif
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.primary.opacity(0.08), lineWidth: 1)
            )

            // Section Footer
            if let footer = footerKey {
                Text(LocalizedStringKey(footer))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 6)
            }
        }
    }
}

struct SettingsView: View {
    @ObservedObject private var audioService = AudioService.shared
    @Environment(\.presentationMode) private var presentationMode
    @State private var activeGameCenterSheet: GameCenterSheetType? = nil
    @State private var isShowingStore: Bool = false

    private let appStoreReviewURL = URL(string: "https://apps.apple.com/app/id422855012?action=write-review")!
    private let websiteURL = URL(string: "https://beling.pl")!
    private let facebookURL = URL(string: "https://facebook.com/pl.beling")!

    var body: some View {
        #if os(macOS) || os(tvOS)
        VStack(spacing: 0) {
            // Header Bar
            HStack {
                Text(LocalizedStringKey("nav_settings"))
                    .font(.title2.bold())
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text(LocalizedStringKey("nav_done"))
                        .font(.headline)
                }
                .buttonStyle(FunActionButtonStyle())
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)

            Divider()

            ScrollView {
                VStack(spacing: 24) {
                    // Section 1: Audio & Sound
                    SettingsCardSection(titleKey: "settings_header_audio", iconName: "speaker.wave.2.fill", iconColor: .blue, footerKey: "settings_footer_audio") {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(LocalizedStringKey("settings_sound_effects"))
                                    .font(.body.weight(.medium))
                                Text(LocalizedStringKey("settings_sound_subtext"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Toggle("", isOn: $audioService.isSoundEnabled)
                                .labelsHidden()
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 14)

                        Divider().padding(.leading, 18)

                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(LocalizedStringKey("settings_bg_music"))
                                    .font(.body.weight(.medium))
                                Text(LocalizedStringKey("settings_music_subtext"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Toggle("", isOn: $audioService.isMusicEnabled)
                                .labelsHidden()
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 14)
                    }

                    // Section 2: Store & Premium
                    SettingsCardSection(titleKey: "settings_header_store", iconName: "cart.fill", iconColor: FunColors.chalkboardGreen) {
                        Button(action: {
                            isShowingStore = true
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(LocalizedStringKey("settings_unlock_premium"))
                                        .font(.body.weight(.medium))
                                        .foregroundColor(.primary)
                                    Text(LocalizedStringKey("settings_unlock_subtext"))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 14)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }

                    // Section 3: Game Center Integration
                    SettingsCardSection(titleKey: "settings_header_gamecenter", iconName: "gamecontroller.fill", iconColor: .green, footerKey: "settings_footer_gamecenter") {
                        Button(action: {
                            activeGameCenterSheet = .achievements
                        }) {
                            HStack {
                                Image(systemName: "trophy.fill")
                                    .foregroundColor(.orange)
                                    .font(.headline)
                                    .frame(width: 24)
                                Text(LocalizedStringKey("settings_achievements"))
                                    .font(.body.weight(.medium))
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 14)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        Divider().padding(.leading, 50)

                        Button(action: {
                            activeGameCenterSheet = .leaderboards
                        }) {
                            HStack {
                                Image(systemName: "list.number")
                                    .foregroundColor(.green)
                                    .font(.headline)
                                    .frame(width: 24)
                                Text(LocalizedStringKey("settings_leaderboards"))
                                    .font(.body.weight(.medium))
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 14)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }

                    // Section 4: Links & Support
                    SettingsCardSection(titleKey: "settings_header_links", iconName: "link", iconColor: .blue, footerKey: "settings_footer_links") {
                        #if os(tvOS)
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "star.bubble.fill")
                                    .foregroundColor(.yellow)
                                    .font(.headline)
                                    .frame(width: 24)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(LocalizedStringKey("settings_rate_appstore"))
                                        .font(.body.weight(.medium))
                                        .foregroundColor(.primary)
                                    Text(LocalizedStringKey("settings_rate_subtext"))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 14)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(FunActionButtonStyle())

                        Divider().padding(.leading, 50)

                        Button(action: {}) {
                            HStack {
                                Image(systemName: "safari.fill")
                                    .foregroundColor(.blue)
                                    .font(.headline)
                                    .frame(width: 24)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(LocalizedStringKey("settings_visit_website"))
                                        .font(.body.weight(.medium))
                                        .foregroundColor(.primary)
                                    Text("https://beling.pl")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text("beling.pl")
                                    .font(.callout.bold())
                                    .foregroundColor(.blue)
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 14)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(FunActionButtonStyle())

                        Divider().padding(.leading, 50)

                        Button(action: {}) {
                            HStack {
                                Image(systemName: "hand.thumbsup.fill")
                                    .foregroundColor(.blue)
                                    .font(.headline)
                                    .frame(width: 24)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(LocalizedStringKey("settings_facebook_page"))
                                        .font(.body.weight(.medium))
                                        .foregroundColor(.primary)
                                    Text("https://facebook.com/pl.beling")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text("facebook.com/pl.beling")
                                    .font(.callout.bold())
                                    .foregroundColor(.blue)
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 14)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(FunActionButtonStyle())
                        #else
                        Link(destination: appStoreReviewURL) {
                            HStack {
                                Image(systemName: "star.bubble.fill")
                                    .foregroundColor(.yellow)
                                    .font(.headline)
                                    .frame(width: 24)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(LocalizedStringKey("settings_rate_appstore"))
                                        .font(.body.weight(.medium))
                                        .foregroundColor(.primary)
                                    Text(LocalizedStringKey("settings_rate_subtext"))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 14)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        Divider().padding(.leading, 50)

                        Link(destination: websiteURL) {
                            HStack {
                                Image(systemName: "safari.fill")
                                    .foregroundColor(.blue)
                                    .font(.headline)
                                    .frame(width: 24)
                                Text(LocalizedStringKey("settings_visit_website"))
                                    .font(.body.weight(.medium))
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 14)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        Divider().padding(.leading, 50)

                        Link(destination: facebookURL) {
                            HStack {
                                Image(systemName: "hand.thumbsup.fill")
                                    .foregroundColor(.blue)
                                    .font(.headline)
                                    .frame(width: 24)
                                Text(LocalizedStringKey("settings_facebook_page"))
                                    .font(.body.weight(.medium))
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 14)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        #endif
                    }
                }
                #if os(tvOS)
                .padding(.horizontal, 56)
                .padding(.vertical, 36)
                #else
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
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
        .sheet(item: $activeGameCenterSheet) { sheetType in
            GameCenterView(state: sheetType.gcState)
        }
        .sheet(isPresented: $isShowingStore) {
            StoreView()
                #if os(macOS)
                .frame(minWidth: 640, idealWidth: 700, minHeight: 700, idealHeight: 780)
                #elseif os(tvOS)
                .frame(minWidth: 1100, idealWidth: 1300, maxWidth: 1500, minHeight: 800, idealHeight: 900, maxHeight: 1000)
                #endif
        }
        #else
        NavigationView {
            Form {
                // Section 1: Audio & Sound
                Section(header: Text(LocalizedStringKey("settings_header_audio")), footer: Text(LocalizedStringKey("settings_footer_audio"))) {
                    Toggle(isOn: $audioService.isSoundEnabled) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(LocalizedStringKey("settings_sound_effects"))
                                    .font(.body)
                                Text(LocalizedStringKey("settings_sound_subtext"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: audioService.isSoundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                                .foregroundColor(audioService.isSoundEnabled ? .blue : .gray)
                        }
                    }

                    Toggle(isOn: $audioService.isMusicEnabled) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(LocalizedStringKey("settings_bg_music"))
                                    .font(.body)
                                Text(LocalizedStringKey("settings_music_subtext"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: audioService.isMusicEnabled ? "music.note" : "music.note.list")
                                .foregroundColor(audioService.isMusicEnabled ? .purple : .gray)
                        }
                    }
                }

                // Section 2: Store & Premium
                Section(header: Text(LocalizedStringKey("settings_header_store"))) {
                    Button(action: {
                        isShowingStore = true
                    }) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    Text(LocalizedStringKey("settings_unlock_premium"))
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Text(LocalizedStringKey("settings_unlock_subtext"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "cart.fill")
                                .foregroundColor(.purple)
                        }
                    }
                }

                // Section 3: Game Center Integration
                Section(header: Text(LocalizedStringKey("settings_header_gamecenter")), footer: Text(LocalizedStringKey("settings_footer_gamecenter"))) {
                    Button(action: {
                        activeGameCenterSheet = .achievements
                    }) {
                        Label {
                            HStack {
                                Text(LocalizedStringKey("settings_achievements"))
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "trophy.fill")
                                .foregroundColor(.orange)
                        }
                    }

                    Button(action: {
                        activeGameCenterSheet = .leaderboards
                    }) {
                        Label {
                            HStack {
                                Text(LocalizedStringKey("settings_leaderboards"))
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "list.number")
                                .foregroundColor(.green)
                        }
                    }
                }

                // Section 4: Links & Support
                Section(header: Text(LocalizedStringKey("settings_header_links")), footer: Text(LocalizedStringKey("settings_footer_links"))) {
                    Link(destination: appStoreReviewURL) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    Text(LocalizedStringKey("settings_rate_appstore"))
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "arrow.up.right.square")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Text(LocalizedStringKey("settings_rate_subtext"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "star.bubble.fill")
                                .foregroundColor(.yellow)
                        }
                    }

                    Link(destination: websiteURL) {
                        Label {
                            HStack {
                                Text(LocalizedStringKey("settings_visit_website"))
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "safari.fill")
                                .foregroundColor(.blue)
                        }
                    }

                    Link(destination: facebookURL) {
                        Label {
                            HStack {
                                Text(LocalizedStringKey("settings_facebook_page"))
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "hand.thumbsup.fill")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle(LocalizedStringKey("nav_settings"))
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
            .sheet(item: $activeGameCenterSheet) { sheetType in
                GameCenterView(state: sheetType.gcState)
            }
            .sheet(isPresented: $isShowingStore) {
                StoreView()
            }
        }
        #endif
    }
}

// MARK: - GameCenter Representable Wrapper (iOS/tvOS/macOS)
#if canImport(UIKit)
import UIKit

struct GameCenterView: UIViewControllerRepresentable {
    let state: GKGameCenterViewControllerState
    var leaderboardID: String? = nil
    @Environment(\.presentationMode) private var presentationMode

    func makeUIViewController(context: Context) -> GKGameCenterViewController {
        let gcVC: GKGameCenterViewController
        if let leaderID = leaderboardID, !leaderID.isEmpty {
            gcVC = GKGameCenterViewController(leaderboardID: leaderID, playerScope: .global, timeScope: .allTime)
        } else {
            gcVC = GKGameCenterViewController(state: state)
        }
        gcVC.gameCenterDelegate = context.coordinator
        return gcVC
    }

    func updateUIViewController(_ uiViewController: GKGameCenterViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, GKGameCenterControllerDelegate {
        var parent: GameCenterView

        init(_ parent: GameCenterView) {
            self.parent = parent
        }

        func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
#elseif canImport(AppKit)
import AppKit

struct GameCenterView: NSViewControllerRepresentable {
    let state: GKGameCenterViewControllerState
    var leaderboardID: String? = nil
    @Environment(\.presentationMode) private var presentationMode

    func makeNSViewController(context: Context) -> GKGameCenterViewController {
        let gcVC: GKGameCenterViewController
        if let leaderID = leaderboardID, !leaderID.isEmpty {
            gcVC = GKGameCenterViewController(leaderboardID: leaderID, playerScope: .global, timeScope: .allTime)
        } else {
            gcVC = GKGameCenterViewController(state: state)
        }
        gcVC.gameCenterDelegate = context.coordinator
        return gcVC
    }

    func updateNSViewController(_ nsViewController: GKGameCenterViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, GKGameCenterControllerDelegate {
        var parent: GameCenterView

        init(_ parent: GameCenterView) {
            self.parent = parent
        }

        func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
#endif

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

import Foundation
import GameKit
import Combine

struct PlayerProfile: Identifiable, Equatable {
    let id: String
    let displayName: String
    let isGameCenter: Bool
}

class ProfileManager: ObservableObject {
    static let shared = ProfileManager()

    @Published var activeProfile: PlayerProfile
    @Published var availableProfiles: [PlayerProfile] = []

    private let selectedProfileKey = "ifunschool_v2_selected_player_id"
    private let gcPlayerIDKey = "ifunschool_v2_saved_gc_player_id"
    private let gcDisplayNameKey = "ifunschool_v2_saved_gc_display_name"

    init() {
        let savedGCID = UserDefaults.standard.string(forKey: gcPlayerIDKey) ?? ""
        let savedGCName = UserDefaults.standard.string(forKey: gcDisplayNameKey) ?? NSLocalizedString("profile_gc_user", comment: "Game Center Player")
        let savedSelectedID = UserDefaults.standard.string(forKey: selectedProfileKey)

        let localName = NSLocalizedString("profile_local_user", comment: "Local Player")
        let localProfile = PlayerProfile(id: "local_user", displayName: localName, isGameCenter: false)

        var profiles: [PlayerProfile] = []
        if !savedGCID.isEmpty {
            profiles.append(PlayerProfile(id: savedGCID, displayName: savedGCName, isGameCenter: true))
        }
        profiles.append(localProfile)

        self.availableProfiles = profiles

        let initialID: String
        if let selected = savedSelectedID, !selected.isEmpty {
            initialID = selected
        } else if !savedGCID.isEmpty {
            initialID = savedGCID
        } else {
            initialID = "local_user"
        }

        if let active = profiles.first(where: { $0.id == initialID }) {
            self.activeProfile = active
        } else {
            self.activeProfile = localProfile
        }

        ScoreStorage.shared.switchUser(playerID: self.activeProfile.id)
    }

    func updateGameCenterPlayer(id: String, displayName: String) {
        guard !id.isEmpty else { return }

        let cleanName = displayName.isEmpty ? NSLocalizedString("profile_gc_user", comment: "Game Center Player") : displayName

        UserDefaults.standard.set(id, forKey: gcPlayerIDKey)
        UserDefaults.standard.set(cleanName, forKey: gcDisplayNameKey)

        let gcProfile = PlayerProfile(id: id, displayName: cleanName, isGameCenter: true)
        let localName = NSLocalizedString("profile_local_user", comment: "Local Player")
        let localProfile = PlayerProfile(id: "local_user", displayName: localName, isGameCenter: false)

        self.availableProfiles = [gcProfile, localProfile]

        let userSelectedID = UserDefaults.standard.string(forKey: selectedProfileKey)
        if userSelectedID == "local_user" {
            selectProfile(localProfile)
        } else {
            selectProfile(gcProfile)
        }
    }

    func selectProfile(_ profile: PlayerProfile) {
        activeProfile = profile
        UserDefaults.standard.set(profile.id, forKey: selectedProfileKey)
        ScoreStorage.shared.switchUser(playerID: profile.id)
        NotificationCenter.default.post(name: NSNotification.Name("iFunSchoolItemProgressUpdated"), object: nil)
    }
}

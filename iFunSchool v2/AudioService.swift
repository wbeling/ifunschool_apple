import Foundation
import AVFoundation
import Combine

class AudioService: ObservableObject {
    static let shared = AudioService()

    private let soundKey = "is_sound_enabled"
    private let musicKey = "is_music_enabled"

    @Published var isSoundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isSoundEnabled, forKey: soundKey)
        }
    }

    @Published var isMusicEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isMusicEnabled, forKey: musicKey)
            if !isMusicEnabled {
                stopMusic()
            }
        }
    }

    private var soundPlayer: AVAudioPlayer?
    private var musicPlayer: AVAudioPlayer?

    init() {
        // Default to true if key not set
        if UserDefaults.standard.object(forKey: soundKey) == nil {
            UserDefaults.standard.set(true, forKey: soundKey)
        }
        if UserDefaults.standard.object(forKey: musicKey) == nil {
            UserDefaults.standard.set(true, forKey: musicKey)
        }

        self.isSoundEnabled = UserDefaults.standard.bool(forKey: soundKey)
        self.isMusicEnabled = UserDefaults.standard.bool(forKey: musicKey)

        configureAudioSession()
    }

    private func configureAudioSession() {
        do {
            #if(!os(macOS))
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            #endif
        } catch {
            print("AudioSession setup error: \(error.localizedDescription)")
        }
    }

    // MARK: - Sound Effects
    func playGoodSound() {
        guard isSoundEnabled else { return }
        let randomIndex = Int.random(in: 1...4)
        playSoundFile(named: "Good\(randomIndex)")
    }

    func playBadSound() {
        guard isSoundEnabled else { return }
        let randomIndex = Int.random(in: 1...4)
        playSoundFile(named: "Bad\(randomIndex)")
    }

    func playGameOverSound() {
        stopMusic()
        guard isSoundEnabled else { return }
        playSoundFile(named: "GameOver")
    }

    private func playSoundFile(named name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "m4a") else {
            print("Sound file not found: \(name).m4a")
            return
        }

        do {
            soundPlayer = try AVAudioPlayer(contentsOf: url)
            soundPlayer?.volume = 1.0
            soundPlayer?.prepareToPlay()
            soundPlayer?.play()
        } catch {
            print("Error playing sound \(name): \(error.localizedDescription)")
        }
    }

    // MARK: - Background Music
    func startMusic() {
        guard isMusicEnabled else { return }
        let randomIndex = Int.random(in: 1...6)
        let musicName = "Music\(randomIndex)"

        guard let url = Bundle.main.url(forResource: musicName, withExtension: "m4a") else {
            print("Music file not found: \(musicName).m4a")
            return
        }

        do {
            stopMusic()
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            musicPlayer?.numberOfLoops = -1 // Loop continuously during game
            musicPlayer?.volume = 0.6
            musicPlayer?.prepareToPlay()
            musicPlayer?.play()
        } catch {
            print("Error starting music \(musicName): \(error.localizedDescription)")
        }
    }

    func stopMusic() {
        if let player = musicPlayer, player.isPlaying {
            player.stop()
        }
        musicPlayer = nil
    }
}

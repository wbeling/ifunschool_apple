import Foundation
import SwiftUI

enum GameType: Int, CaseIterable, Identifiable {
    case addition = 1
    case multiplication = 2
    case subtraction = 3
    case division = 4
    case order = 5
    case sequences = 6
    case equations = 7
    case memoryAdd = 8
    case memoryAddSub = 9
    case memoryAddSubMult = 10
    case memoryShapes = 11
    case memoryColors = 12
    case chemSymbols = 13
    case chemNames = 14
    case flags = 15

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .addition: return NSLocalizedString("game_addition", comment: "Addition")
        case .multiplication: return NSLocalizedString("game_multiplication", comment: "Multiplication")
        case .subtraction: return NSLocalizedString("game_subtraction", comment: "Subtraction")
        case .division: return NSLocalizedString("game_division", comment: "Division")
        case .order: return NSLocalizedString("game_order", comment: "Order")
        case .sequences: return NSLocalizedString("game_sequences", comment: "Sequences")
        case .equations: return NSLocalizedString("game_equations", comment: "Equations")
        case .memoryAdd: return NSLocalizedString("game_memory_add", comment: "Memory Add")
        case .memoryAddSub: return NSLocalizedString("game_memory_add_sub", comment: "Memory Add/Sub")
        case .memoryAddSubMult: return NSLocalizedString("game_memory_add_sub_mult", comment: "Memory Math Ops")
        case .memoryShapes: return NSLocalizedString("game_memory_shapes", comment: "Memory Shapes")
        case .memoryColors: return NSLocalizedString("game_memory_colors", comment: "Memory Colors")
        case .chemSymbols: return NSLocalizedString("game_chem_symbols", comment: "Chemical Symbols")
        case .chemNames: return NSLocalizedString("game_chem_names", comment: "Chemical Names")
        case .flags: return NSLocalizedString("game_flags", comment: "Country Flags")
        }
    }

    var systemIcon: String {
        switch self {
        case .addition: return "plus.circle.fill"
        case .multiplication: return "multiply.circle.fill"
        case .subtraction: return "minus.circle.fill"
        case .division: return "divide.circle.fill"
        case .order: return "list.number"
        case .sequences: return "chart.line.uptrend.xyaxis"
        case .equations: return "function"
        case .memoryAdd: return "brain.head.profile"
        case .memoryAddSub: return "brain"
        case .memoryAddSubMult: return "sparkles"
        case .memoryShapes: return "square.on.circle"
        case .memoryColors: return "paintpalette.fill"
        case .chemSymbols: return "atom"
        case .chemNames: return "flask.fill"
        case .flags: return "flag.fill"
        }
    }
}

enum GameLevel: Int, CaseIterable, Identifiable, Comparable {
    case beginner = 0
    case easy = 1
    case medium = 2
    case hard = 3
    case ultimate = 4
    case godlike = 5

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .beginner: return NSLocalizedString("level_beginner", comment: "Beginner")
        case .easy: return NSLocalizedString("level_easy", comment: "Easy")
        case .medium: return NSLocalizedString("level_medium", comment: "Medium")
        case .hard: return NSLocalizedString("level_hard", comment: "Hard")
        case .ultimate: return NSLocalizedString("level_ultimate", comment: "Ultimate")
        case .godlike: return NSLocalizedString("level_godlike", comment: "Godlike")
        }
    }

    var badgeColor: Color {
        switch self {
        case .beginner: return .green
        case .easy: return .blue
        case .medium: return .orange
        case .hard: return .purple
        case .ultimate: return .red
        case .godlike: return .black
        }
    }

    static func < (lhs: GameLevel, rhs: GameLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

enum GameStatus {
    case unplayed
    case standard
    case perfect
    case locked

    var title: String {
        switch self {
        case .locked: return NSLocalizedString("status_locked", comment: "Locked")
        case .unplayed: return NSLocalizedString("status_unplayed", comment: "Unplayed")
        case .standard: return NSLocalizedString("status_played", comment: "Played")
        case .perfect: return NSLocalizedString("status_perfect", comment: "Perfect")
        }
    }
}

enum LockReason {
    case notEnoughStars
    case starLimitCapped
    case godlikeLocked
    case requiresSubscription
    case requiresPurchase
}

struct GameItem: Identifiable {
    let id: String // e.g. "1_0" (gameType_gameLevel)
    let gameType: GameType
    let level: GameLevel
    let requiredGoldStars: Int
    let requiredSilverStars: Int
    var status: GameStatus = .unplayed
    var lockReason: LockReason? = nil
    var topScore: Double = 0.0
    var topTime: Int = 0
    var topStars: Int = 0

    // Computed property aliases for ContentView & GameListViewModel compatibility
    var gameStatus: GameStatus {
        get { status }
        set { status = newValue }
    }

    var isUnlocked: Bool {
        status != .locked
    }

    var highScore: Int {
        get { Int(topScore) }
        set { topScore = Double(newValue) }
    }

    var perfectTime: Int {
        get { topTime }
        set { topTime = newValue }
    }

    var levelStars: Int {
        get { topStars }
        set { topStars = newValue }
    }
}

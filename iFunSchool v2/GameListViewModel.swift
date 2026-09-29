import Foundation
import Combine

@MainActor
class GameListViewModel: ObservableObject {
    @Published var games: [GameItem] = []
    @Published var expandedGameId: String? = nil
    @Published var selectedLevel: GameLevel? = nil
    
    @Published var rawGoldStars: Int = 0
    @Published var totalGoldStars: Int = 0
    @Published var isStarLimitReached: Bool = false
    @Published var totalSilverStars: Int = 0
    @Published var totalScore: Double = 0.0
    
    private let gamesPerPage = 15
    private var cancellables = Set<AnyCancellable>()

    init() {
        populateGameList()
        loadUserScores()

        NotificationCenter.default.publisher(for: NSNotification.Name("iFunSchoolScoreUpdated"))
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.populateGameList()
                    self?.loadUserScores()
                }
            }
            .store(in: &cancellables)
    }

    var availableLevels: [GameLevel] {
        return GameLevel.allCases
    }

    func populateGameList() {
        var items: [GameItem] = []
        let levels: [GameLevel] = [.beginner, .easy, .medium, .hard, .ultimate, .godlike]

        for level in levels {
            for typeIndex in 1...gamesPerPage {
                guard let gameType = GameType(rawValue: typeIndex) else { continue }
                
                let zl = max(0, (typeIndex - 1) + ((level.rawValue - 1) * gamesPerPage))
                let reqGold = (level == .godlike) ? 0 : zl
                let reqSilver = 0

                let id = "\(gameType.rawValue)_\(level.rawValue)"
                let item = GameItem(
                    id: id,
                    gameType: gameType,
                    level: level,
                    requiredGoldStars: reqGold,
                    requiredSilverStars: reqSilver
                )
                items.append(item)
            }
        }
        self.games = items
    }

    func loadUserScores() {
        ScoreStorage.shared.loadAllScores()

        let scoresDict = ScoreStorage.shared.scoresDict
        let rawGoldCount = ScoreStorage.shared.totalGoldStars
        let silverCount = ScoreStorage.shared.totalSilverStars
        let scoreSum = ScoreStorage.shared.totalScore

        let isGodlikeUnlocked = StoreKitService.shared.isGodlikeUnlocked
        let isStarLimitUnlocked = StoreKitService.shared.isStarLimitUnlocked

        self.rawGoldStars = rawGoldCount
        if isStarLimitUnlocked {
            self.totalGoldStars = rawGoldCount
            self.isStarLimitReached = false
        } else {
            self.totalGoldStars = min(rawGoldCount, 15)
            self.isStarLimitReached = (rawGoldCount >= 15)
        }

        self.totalSilverStars = silverCount
        self.totalScore = scoreSum

        // Update games with status, stars, and lock reason
        for i in 0..<games.count {
            let keyStr = "\(games[i].gameType.rawValue)_\(games[i].level.rawValue)"
            let reqGold = games[i].requiredGoldStars

            let hasEnoughGoldStars = (self.totalGoldStars >= reqGold)
            let isGodlike = (games[i].level == .godlike)

            if isGodlike {
                if !isGodlikeUnlocked {
                    games[i].gameStatus = .locked
                    games[i].lockReason = .requiresPurchase
                    games[i].highScore = 0
                    games[i].perfectTime = 0
                    games[i].levelStars = 0
                } else {
                    games[i].lockReason = nil
                    if let record = scoresDict[keyStr] {
                        games[i].highScore = Int(record.topScore)
                        games[i].perfectTime = record.topTime
                        games[i].levelStars = record.topStars

                        if record.topStars == 0 {
                            games[i].gameStatus = .unplayed
                        } else if record.topStars >= 5 {
                            games[i].gameStatus = .perfect
                        } else {
                            games[i].gameStatus = .standard
                        }
                    } else {
                        games[i].highScore = 0
                        games[i].perfectTime = 0
                        games[i].levelStars = 0
                        games[i].gameStatus = .unplayed
                    }
                }
            } else if !hasEnoughGoldStars {
                games[i].gameStatus = .locked
                if reqGold >= 16 && !isStarLimitUnlocked {
                    games[i].lockReason = .requiresPurchase
                } else {
                    games[i].lockReason = .notEnoughStars
                }
                games[i].highScore = 0
                games[i].perfectTime = 0
                games[i].levelStars = 0
            } else {
                games[i].lockReason = nil
                if let record = scoresDict[keyStr] {
                    games[i].highScore = Int(record.topScore)
                    games[i].perfectTime = record.topTime
                    games[i].levelStars = record.topStars

                    if record.topStars == 0 {
                        games[i].gameStatus = .unplayed
                    } else if record.topStars >= 5 {
                        games[i].gameStatus = .perfect
                    } else {
                        games[i].gameStatus = .standard
                    }
                } else {
                    games[i].highScore = 0
                    games[i].perfectTime = 0
                    games[i].levelStars = 0
                    games[i].gameStatus = .unplayed
                }
            }
        }

        objectWillChange.send()
    }

    func toggleExpand(gameId: String) {
        if expandedGameId == gameId {
            expandedGameId = nil
        } else {
            expandedGameId = gameId
        }
    }

    var filteredGames: [GameItem] {
        if let level = selectedLevel {
            return games.filter { $0.level == level }
        }
        return games
    }
}

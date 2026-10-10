import Foundation
import Combine
import SwiftUI

class GameViewModel: ObservableObject {
    let gameType: GameType
    let level: GameLevel

    @Published var currentQuestionIndex: Int = 0
    @Published var totalQuestions: Int = 15
    private var pregeneratedQuestions: [Question] = []
    @Published var currentQuestion: Question? = nil

    @Published var timeRemaining: Double = 0.0
    @Published var maxQuestionTime: Double = 20.0
    @Published var questionScore: Double = 0.0
    @Published var gameScore: Double = 0.0

    @Published var correctCount: Int = 0
    @Published var wrongCount: Int = 0

    @Published var selectedAnswerIndex: Int? = nil
    @Published var isFeedbackShowing: Bool = false
    @Published var isGameOver: Bool = false
    @Published var earnedStars: Int = 0

    // Memory Phase animation state
    @Published var isMemoryPhase: Bool = false
    @Published var currentMemoryStepIndex: Int = 0
    @Published var memoryPreviewCountdown: Double = 0.0

    @Published var isNewHighScore: Bool = false
    @Published var isNewStarsRecord: Bool = false
    @Published var newlyUnlockedAchievements: [String] = []

    private var timerSubscription: AnyCancellable?
    private var memoryTimerSubscription: AnyCancellable?

    init(
        gameType: GameType,
        level: GameLevel,
        currentQuestion: Question? = nil,
        totalQuestions: Int? = nil,
        currentQuestionIndex: Int = 1,
        timeRemaining: Double = 15.0,
        gameScore: Double = 0.0,
        autoStart: Bool = true
    ) {
        self.gameType = gameType
        self.level = level
        self.totalQuestions = totalQuestions ?? QuestionGenerator.shared.TotalQuestions(for: level)
        self.maxQuestionTime = QuestionGenerator.shared.getMaxTime(for: level)
        self.currentQuestion = currentQuestion
        self.currentQuestionIndex = currentQuestionIndex
        self.timeRemaining = timeRemaining
        self.gameScore = gameScore
        
        if autoStart {
            startNewGame()
        }
    }

    func startNewGame() {
        currentQuestionIndex = 0
        gameScore = 0.0
        correctCount = 0
        wrongCount = 0
        isGameOver = false
        earnedStars = 0
        isNewHighScore = false
        isNewStarsRecord = false
        newlyUnlockedAchievements = []
        
        self.pregeneratedQuestions = QuestionGenerator.shared.generateGameQuestions(
            gameType: gameType,
            level: level,
            playerID: ScoreStorage.shared.activePlayerID,
            count: 15
        )
        self.totalQuestions = pregeneratedQuestions.count
        AudioService.shared.startMusic()
        loadNextQuestion()
    }

    func loadNextQuestion() {
        stopTimer()
        stopMemoryTimer()
        selectedAnswerIndex = nil
        isFeedbackShowing = false

        if currentQuestionIndex >= totalQuestions {
            finishGame()
            return
        }

        currentQuestionIndex += 1
        let questionIndex = currentQuestionIndex - 1
        guard questionIndex >= 0 && questionIndex < pregeneratedQuestions.count else {
            finishGame()
            return
        }
        let question = pregeneratedQuestions[questionIndex]
        self.currentQuestion = question
        self.timeRemaining = question.maxTime
        self.questionScore = question.maxTime * QuestionGenerator.shared.scoreMultiplier(for: level)

        if let steps = question.memorySteps, !steps.isEmpty {
            startMemoryStepsPhase(stepsCount: steps.count)
        } else if let gridItems = question.memoryGridItems, !gridItems.isEmpty, let previewSecs = question.memoryPreviewSeconds {
            startMemoryGridPhase(seconds: previewSecs)
        } else {
            isMemoryPhase = false
            startTimer()
        }
    }

    private func startMemoryStepsPhase(stepsCount: Int) {
        isMemoryPhase = true
        currentMemoryStepIndex = 0
        stopMemoryTimer()

        let stepDuration: Double = 1.2
        memoryTimerSubscription = Timer.publish(every: stepDuration, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.currentMemoryStepIndex < stepsCount - 1 {
                    self.currentMemoryStepIndex += 1
                    HapticService.shared.playSelection()
                } else {
                    // Memory sequence finished! Activate question countdown and answers grid
                    self.stopMemoryTimer()
                    self.isMemoryPhase = false
                    self.startTimer()
                }
            }
    }

    private func startMemoryGridPhase(seconds: Double) {
        isMemoryPhase = true
        memoryPreviewCountdown = seconds
        stopMemoryTimer()

        memoryTimerSubscription = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.memoryPreviewCountdown > 0.1 {
                    self.memoryPreviewCountdown -= 0.1
                } else {
                    self.memoryPreviewCountdown = 0.0
                    self.stopMemoryTimer()
                    self.isMemoryPhase = false
                    self.startTimer()
                }
            }
    }

    private func stopMemoryTimer() {
        memoryTimerSubscription?.cancel()
        memoryTimerSubscription = nil
    }

    private func startTimer() {
        stopTimer()
        timerSubscription = Timer.publish(every: 0.05, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, !self.isFeedbackShowing, !self.isGameOver, !self.isMemoryPhase else { return }
                
                if self.timeRemaining > 0.05 {
                    self.timeRemaining -= 0.05
                    self.questionScore = self.timeRemaining * QuestionGenerator.shared.scoreMultiplier(for: self.level)
                } else {
                    self.timeRemaining = 0
                    self.questionScore = 0
                    self.handleTimeExpired()
                }
            }
    }

    private func stopTimer() {
        timerSubscription?.cancel()
        timerSubscription = nil
    }

    func selectAnswer(index: Int) {
        guard !isMemoryPhase, !isFeedbackShowing, selectedAnswerIndex == nil, let question = currentQuestion else { return }

        stopTimer()
        selectedAnswerIndex = index
        isFeedbackShowing = true

        let isCorrect = (index == question.correctIndex)
        ItemProgressTracker.shared.updateStatus(itemKey: question.itemKey, isCorrect: isCorrect, playerID: ScoreStorage.shared.activePlayerID)

        if isCorrect {
            correctCount += 1
            gameScore += questionScore
            AudioService.shared.playGoodSound()
            HapticService.shared.playSuccess()
        } else {
            wrongCount += 1
            AudioService.shared.playBadSound()
            HapticService.shared.playError()
        }

        // Transition to next question after 1 second feedback delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.loadNextQuestion()
        }
    }

    private func handleTimeExpired() {
        stopTimer()
        if let question = currentQuestion {
            ItemProgressTracker.shared.updateStatus(itemKey: question.itemKey, isCorrect: false, playerID: ScoreStorage.shared.activePlayerID)
        }
        wrongCount += 1
        isFeedbackShowing = true
        selectedAnswerIndex = -1 // No answer selected in time
        AudioService.shared.playBadSound()
        HapticService.shared.playError()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.loadNextQuestion()
        }
    }

    private func finishGame() {
        stopTimer()
        stopMemoryTimer()
        
        let accuracy = Double(correctCount) / Double(max(1, totalQuestions))
        if accuracy >= 1.0 {
            earnedStars = 5 // Gold star!
        } else if accuracy >= 0.8 {
            earnedStars = 4
        } else if accuracy >= 0.6 {
            earnedStars = 3
        } else if accuracy >= 0.4 {
            earnedStars = 2
        } else if accuracy >= 0.2 {
            earnedStars = 1
        } else {
            earnedStars = 0
        }

        // Play Game Over Sound
        AudioService.shared.playGameOverSound()

        // 1. Save score to ScoreStorage
        let totalSecondsTaken = Int(maxQuestionTime * Double(totalQuestions) - timeRemaining)
        let saveResult = ScoreStorage.shared.saveScore(
            gameType: gameType,
            level: level,
            score: gameScore,
            stars: earnedStars,
            time: max(1, totalSecondsTaken)
        )

        self.isNewHighScore = saveResult.isNewHighScore
        self.isNewStarsRecord = saveResult.isNewStarsRecord

        if earnedStars > 0 {
            StreakTracker.shared.recordGameCompleted(stars: earnedStars, affectedLevel: level) { [weak self] in
                guard let self = self else { return }
                let totalGold = ScoreStorage.shared.totalGoldStars
                let totalSilver = ScoreStorage.shared.totalSilverStars
                let totalScore = ScoreStorage.shared.totalScore

                let newUnlocks = AchievementService.shared.evaluateAndReport(
                    totalGoldStars: totalGold,
                    totalSilverStars: totalSilver,
                    totalScore: totalScore,
                    affectedLevel: self.level
                )
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    self.newlyUnlockedAchievements = newUnlocks
                }
            }
        } else {
            let totalGold = ScoreStorage.shared.totalGoldStars
            let totalSilver = ScoreStorage.shared.totalSilverStars
            let totalScore = ScoreStorage.shared.totalScore

            let newUnlocks = AchievementService.shared.evaluateAndReport(
                totalGoldStars: totalGold,
                totalSilverStars: totalSilver,
                totalScore: totalScore,
                affectedLevel: self.level
            )
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                self.newlyUnlockedAchievements = newUnlocks
            }
        }

        // 3. Record Game Completed and check App Store Review Prompt metrics
        ReviewPromptService.shared.recordGameCompletedAndCheckReview()

        isGameOver = true
    }

    func abortGame() {
        stopTimer()
        stopMemoryTimer()
        AudioService.shared.stopMusic()
        isGameOver = false
    }

    deinit {
        stopTimer()
        stopMemoryTimer()
        AudioService.shared.stopMusic()
    }
    static func mock(
        gameType: GameType = .addition,
        level: GameLevel = .easy,
        question: Question? = nil,
        totalQuestions: Int = 15,
        currentQuestionIndex: Int = 1,
        timeRemaining: Double = 15.0,
        gameScore: Double = 120.0,
        selectedAnswerIndex: Int? = nil,
        isFeedbackShowing: Bool = false,
        isGameOver: Bool = false,
        earnedStars: Int = 0,
        correctCount: Int = 0,
        wrongCount: Int = 0,
        isMemoryPhase: Bool = false,
        currentMemoryStepIndex: Int = 0,
        memoryPreviewCountdown: Double = 0.0
    ) -> GameViewModel {
        let vm = GameViewModel(
            gameType: gameType,
            level: level,
            currentQuestion: question,
            totalQuestions: totalQuestions,
            currentQuestionIndex: currentQuestionIndex,
            timeRemaining: timeRemaining,
            gameScore: gameScore,
            autoStart: false
        )
        vm.selectedAnswerIndex = selectedAnswerIndex
        vm.isFeedbackShowing = isFeedbackShowing
        vm.isGameOver = isGameOver
        vm.earnedStars = earnedStars
        vm.correctCount = correctCount
        vm.wrongCount = wrongCount
        vm.isMemoryPhase = isMemoryPhase
        vm.currentMemoryStepIndex = currentMemoryStepIndex
        vm.memoryPreviewCountdown = memoryPreviewCountdown
        return vm
    }

    static func mockMemoryMath(step: String = "+5") -> GameViewModel {
        let baseQuestion = QuestionGenerator.shared.generateGameQuestions(
            gameType: .memoryAdd,
            level: .easy,
            playerID: ScoreStorage.shared.activePlayerID,
            count: 1
        ).first

        var steps = baseQuestion?.memorySteps ?? [step, "+3", "-2", "+4"]
        if !steps.isEmpty {
            steps[0] = step
        }

        let memoryQuestion = Question(
            text: baseQuestion?.text ?? NSLocalizedString("prompt_memory_math_final", comment: "Final result"),
            subtext: baseQuestion?.subtext ?? NSLocalizedString("prompt_memory_math_subtext", comment: "Remember operations"),
            options: baseQuestion?.options ?? ["12", "15", "17", "20"],
            correctIndex: baseQuestion?.correctIndex ?? 1,
            maxTime: baseQuestion?.maxTime ?? 20.0,
            memorySteps: steps
        )

        return GameViewModel.mock(
            gameType: .memoryAdd,
            level: .easy,
            question: memoryQuestion,
            totalQuestions: 15,
            currentQuestionIndex: 1,
            timeRemaining: 15.0,
            gameScore: 100.0,
            isMemoryPhase: true,
            currentMemoryStepIndex: 0
        )
    }

    static func mockMemoryShapes() -> GameViewModel {
        let generatedQuestion = QuestionGenerator.shared.generateGameQuestions(
            gameType: .memoryShapes,
            level: .easy,
            playerID: ScoreStorage.shared.activePlayerID,
            count: 1
        ).first ?? Question(
            text: "How many circles?",
            subtext: "Remember the shapes",
            options: ["2", "3", "4", "5"],
            correctIndex: 1,
            maxTime: 20.0,
            memoryGridItems: [
                MemoryGridItem(shapeSymbol: "circle.fill", colorName: "BLUE"),
                MemoryGridItem(shapeSymbol: "square.fill", colorName: "PURPLE"),
                MemoryGridItem(shapeSymbol: "triangle.fill", colorName: "ORANGE"),
                MemoryGridItem(shapeSymbol: "star.fill", colorName: "YELLOW"),
                MemoryGridItem(shapeSymbol: "circle.fill", colorName: "GREEN"),
                MemoryGridItem(shapeSymbol: "diamond.fill", colorName: "RED")
            ],
            memoryPreviewSeconds: 6.0
        )

        let countdown = generatedQuestion.memoryPreviewSeconds ?? 6.0

        return GameViewModel.mock(
            gameType: .memoryShapes,
            level: .easy,
            question: generatedQuestion,
            totalQuestions: 15,
            currentQuestionIndex: 2,
            timeRemaining: 15.0,
            gameScore: 160.0,
            isMemoryPhase: true,
            memoryPreviewCountdown: countdown
        )
    }
}

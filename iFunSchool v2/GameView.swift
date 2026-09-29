import SwiftUI

struct GameView: View {
    @StateObject private var viewModel: GameViewModel
    @Environment(\.presentationMode) private var presentationMode
    @State private var showAbortAlert: Bool = false
    var onDismiss: (() -> Void)? = nil

    init(gameType: GameType, level: GameLevel, onDismiss: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: GameViewModel(gameType: gameType, level: level))
        self.onDismiss = onDismiss
    }

    var body: some View {
        Group {
            if viewModel.isGameOver {
                gameOverView
            } else {
                gamePlayContent
            }
        }
        .background(FunColors.bgColor.ignoresSafeArea())
        #if os(iOS) || os(tvOS)
        .navigationBarHidden(true)
        #endif
        .alert(
            NSLocalizedString("alert_quit_title", comment: "Quit Title"),
            isPresented: $showAbortAlert
        ) {
            Button(NSLocalizedString("alert_quit_action", comment: "Quit"), role: .destructive) {
                viewModel.abortGame()
                dismissView()
            }
            Button(NSLocalizedString("common_cancel", comment: "Cancel"), role: .cancel) { }
        } message: {
            Text(NSLocalizedString("alert_quit_message", comment: "Quit Message"))
        }
    }

    private func dismissView() {
        if let onDismiss = onDismiss {
            onDismiss()
        } else {
            presentationMode.wrappedValue.dismiss()
        }
    }

    // MARK: - Game Gameplay Content
    private var gamePlayContent: some View {
        VStack(spacing: 0) {
            // Header Bar (Quit, Game Title, Round Info)
            headerBar

            // Question Progress & Score Bar
            questionProgressBar
                .padding(.vertical, 12)

            // Question Countdown Timer Bar
            timerProgressBar
                .padding(.horizontal, 16)
                .padding(.bottom, 16)

            // Main Question Card
            if let question = viewModel.currentQuestion {
                questionCard(question: question)
                    .padding(.horizontal, 16)
            } else {
                Spacer()
            }

            Spacer(minLength: 16)

            // 4 Answer Options (2x2 Grid)
            if let question = viewModel.currentQuestion {
                answerGrid(question: question)
            }

            Spacer(minLength: 24)
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Header Bar
    private var headerBar: some View {
        ZStack {
            HStack {
                Button(action: {
                    showAbortAlert = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                        Text(LocalizedStringKey("btn_quit"))
                            .font(.body)
                    }
                    .foregroundColor(.red)
                }
                .buttonStyle(FunHeaderButtonStyle())

                Spacer()
            }

            VStack(spacing: 2) {
                Text(viewModel.gameType.title)
                    .font(.headline.bold())
                Text(viewModel.level.title)
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(viewModel.level == .godlike ? Color.black : Color.secondary.opacity(0.15))
                    .foregroundColor(viewModel.level == .godlike ? Color.white : Color.secondary)
                    .cornerRadius(6)
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: - Question Progress & Score Bar
    private var questionProgressBar: some View {
        HStack {
            // Question Counter
            HStack(spacing: 6) {
                Image(systemName: "number.circle.fill")
                    .foregroundColor(.blue)
                Text("\(viewModel.currentQuestionIndex) / \(viewModel.totalQuestions)")
                    .font(.subheadline.weight(.semibold))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)

            Spacer()

            // Total Score
            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .foregroundColor(.orange)
                Text("\(Int(viewModel.gameScore)) pts")
                    .font(.subheadline.weight(.bold))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(12)
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Timer Bar
    private var timerProgressBar: some View {
        VStack(spacing: 4) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.2))

                    if viewModel.isMemoryPhase && viewModel.currentQuestion?.memoryGridItems != nil {
                        // Memory Grid Preview Countdown
                        let ratio = viewModel.memoryPreviewCountdown / max(1.0, viewModel.currentQuestion?.memoryPreviewSeconds ?? 1.0)
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.purple)
                            .frame(width: geometry.size.width * CGFloat(ratio))
                            .animation(.linear(duration: 0.1), value: viewModel.memoryPreviewCountdown)
                    } else {
                        // Question Timer Countdown
                        RoundedRectangle(cornerRadius: 6)
                            .fill(timerColor)
                            .frame(width: geometry.size.width * CGFloat(viewModel.timeRemaining / max(1.0, viewModel.maxQuestionTime)))
                            .animation(.linear(duration: 0.05), value: viewModel.timeRemaining)
                    }
                }
            }
            .frame(height: 10)

            HStack {
                Text(viewModel.isMemoryPhase ? NSLocalizedString("game_memorize_phase", comment: "Memorize Phase") : NSLocalizedString("game_time_left", comment: "Time Left"))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                if viewModel.isMemoryPhase && viewModel.currentQuestion?.memoryGridItems != nil {
                    Text(String(format: "%.1fs", viewModel.memoryPreviewCountdown))
                        .font(.caption2.bold())
                        .foregroundColor(.purple)
                } else {
                    Text(String(format: "%.1fs", viewModel.timeRemaining))
                        .font(.caption2.bold())
                        .foregroundColor(timerColor)
                }
            }
        }
    }

    private var timerColor: Color {
        let ratio = viewModel.timeRemaining / max(1.0, viewModel.maxQuestionTime)
        if ratio > 0.5 {
            return .green
        } else if ratio > 0.25 {
            return .orange
        } else {
            return .red
        }
    }

    // MARK: - Question Card
    private func questionCard(question: Question) -> some View {
        VStack(spacing: 16) {
            if viewModel.isMemoryPhase {
                if let gridItems = question.memoryGridItems, !gridItems.isEmpty {
                    // Memory Grid Preview Phase (Multiple shapes displayed at once)
                    VStack(spacing: 14) {
                        HStack(spacing: 6) {
                            Image(systemName: "eye.fill")
                                .foregroundColor(.purple)
                            Text(NSLocalizedString("game_try_to_remember", comment: "Try to remember:"))
                                .font(.headline.bold())
                                .foregroundColor(.purple)
                            Spacer()
                            Text(String(format: "%.1fs", viewModel.memoryPreviewCountdown))
                                .font(.headline.bold())
                                .foregroundColor(.purple)
                        }
                        .padding(.horizontal, 8)

                        let columns = [
                            GridItem(.adaptive(minimum: 72, maximum: 90), spacing: 14)
                        ]

                        HStack {
                            Spacer(minLength: 0)
                            LazyVGrid(columns: columns, alignment: .center, spacing: 14) {
                                ForEach(gridItems) { item in
                                    Image(systemName: item.shapeSymbol)
                                        .font(.system(size: 54))
                                        .foregroundColor(colorFromName(item.colorName))
                                        .frame(width: 72, height: 72)
                                        .background(FunColors.bgColor3)
                                        .cornerRadius(14)
                                        .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
                                }
                            }
                            Spacer(minLength: 0)
                        }
                        .padding(.vertical, 8)
                    }
                } else if let steps = question.memorySteps, !steps.isEmpty, viewModel.currentMemoryStepIndex < steps.count {
                    // Memory Sequential Steps (Addition, Subtraction, Operations)
                    let currentStepItem = steps[viewModel.currentMemoryStepIndex]

                    VStack(spacing: 12) {
                        Text(question.subtext ?? NSLocalizedString("prompt_memory_math_subtext", comment: "Memorize operations:"))
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text(currentStepItem)
                            .font(.system(size: 64, weight: .bold, design: .rounded))
                            .foregroundColor(.blue)
                            .transition(.scale.combined(with: .opacity))
                            .id("math_\(viewModel.currentMemoryStepIndex)")

                        Text(String(format: NSLocalizedString("game_step_format", comment: "Step %d of %d"), viewModel.currentMemoryStepIndex + 1, steps.count))
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 12)
                }
            } else {
                // Post-Memory Question Prompt or Standard Question
                if let subtext = question.subtext {
                    Text(subtext)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                if let flagImageName = question.flagImageName {
                    // Real Flag Image Display
                    VStack(spacing: 12) {
                        #if canImport(UIKit)
                        if let uiImage = UIImage(named: flagImageName) ?? UIImage(named: "\(flagImageName).png") {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 220, maxHeight: 130)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue.opacity(0.1))
                                    .frame(width: 160, height: 100)
                                
                                Image(systemName: "flag.fill")
                                    .font(.system(size: 48))
                                    .foregroundColor(.blue)
                            }
                        }
                        #elseif canImport(AppKit)
                        if let nsImage = NSImage(named: flagImageName) ?? NSImage(named: "\(flagImageName).png") {
                            Image(nsImage: nsImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 220, maxHeight: 130)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue.opacity(0.1))
                                    .frame(width: 160, height: 100)
                                
                                Image(systemName: "flag.fill")
                                    .font(.system(size: 48))
                                    .foregroundColor(.blue)
                            }
                        }
                        #endif
                    }
                    .padding(.vertical, 4)
                } else {
                    // Formula or Question Prompt
                    Text(question.text)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 8)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
        .background(FunColors.bgColor2)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    private func colorFromName(_ name: String) -> Color {
        switch name.uppercased() {
        case "RED": return .red
        case "BLUE": return .blue
        case "GREEN": return .green
        case "YELLOW": return .yellow
        case "PURPLE": return .purple
        case "ORANGE": return .orange
        default: return .blue
        }
    }

    // MARK: - Answer Grid (2x2 Grid)
    private func answerGrid(question: Question) -> some View {
        let columns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]

        return Group {
            if viewModel.isMemoryPhase {
                // Placeholder notice during memory preview phase
                VStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text(NSLocalizedString("game_memorize_grid_notice", comment: "Memorize grid"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 140)
                .background(FunColors.bgColor2.opacity(0.6))
                .cornerRadius(16)
                .padding(.horizontal, 8)
            } else {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(0..<question.options.count, id: \.self) { idx in
                        let optionText = question.options[idx]
                        
                        Button(action: {
                            viewModel.selectAnswer(index: idx)
                        }) {
                            Text(optionText)
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(buttonTextColor(for: idx, question: question))
                                .frame(maxWidth: .infinity, minHeight: 64)
                                .background(buttonBackgroundColor(for: idx, question: question))
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(buttonBorderColor(for: idx, question: question), lineWidth: 2)
                                )
                                .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                        }
                        .buttonStyle(FunAnswerButtonStyle())
                        .accessibilityIdentifier("btn_answer_\(idx)")
                        .disabled(viewModel.isFeedbackShowing)
                    }
                }
            }
        }
    }

    private func buttonBackgroundColor(for index: Int, question: Question) -> Color {
        guard viewModel.isFeedbackShowing else {
            return FunColors.bgColor2
        }

        if index == question.correctIndex {
            return Color.green.opacity(0.2)
        } else if index == viewModel.selectedAnswerIndex {
            return Color.red.opacity(0.2)
        } else {
            return FunColors.bgColor2.opacity(0.5)
        }
    }

    private func buttonBorderColor(for index: Int, question: Question) -> Color {
        guard viewModel.isFeedbackShowing else {
            return Color.blue.opacity(0.2)
        }

        if index == question.correctIndex {
            return Color.green
        } else if index == viewModel.selectedAnswerIndex {
            return Color.red
        } else {
            return Color.clear
        }
    }

    private func buttonTextColor(for index: Int, question: Question) -> Color {
        guard viewModel.isFeedbackShowing else {
            return .primary
        }

        if index == question.correctIndex {
            return .green
        } else if index == viewModel.selectedAnswerIndex {
            return .red
        } else {
            return .secondary
        }
    }

    // MARK: - Game Over Summary View
    private var gameOverView: some View {
        VStack(spacing: 24) {
            Spacer()

            // Star Rating Header
            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    ForEach(1...5, id: \.self) { star in
                        if star <= viewModel.earnedStars {
                            if star == 5 {
                                Image(systemName: "star.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.yellow)
                            } else {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 36))
                                    .foregroundColor(.gray)
                            }
                        } else {
                            Image(systemName: "star")
                                .font(.system(size: 36))
                                .foregroundColor(.gray.opacity(0.3))
                        }
                    }
                }

                Text(gameOverTitle)
                    .font(.largeTitle.bold())
            }

            // New High Score Badge
            if viewModel.isNewHighScore {
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.yellow)
                    Text(NSLocalizedString("gameover_new_high_score", comment: "NEW HIGH SCORE!"))
                        .font(.headline.bold())
                        .foregroundColor(.yellow)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.yellow.opacity(0.15))
                .cornerRadius(20)
            }

            // Achievement Unlocked Banner
            if !viewModel.newlyUnlockedAchievements.isEmpty {
                VStack(spacing: 4) {
                    HStack {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.orange)
                        Text(NSLocalizedString("gameover_achievement_unlocked", comment: "Achievement Unlocked!"))
                            .font(.subheadline.bold())
                            .foregroundColor(.orange)
                    }
                    ForEach(viewModel.newlyUnlockedAchievements, id: \.self) { ach in
                        Text(ach)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.15))
                .cornerRadius(12)
                .transition(.scale(scale: 0.85).combined(with: .opacity))
            }

            // Score Details Card
            VStack(spacing: 16) {
                HStack {
                    Text(NSLocalizedString("gameover_final_score", comment: "Final Score"))
                    Spacer()
                    Text("\(Int(viewModel.gameScore)) pts")
                        .font(.title3.bold())
                }

                Divider()

                HStack {
                    Text(NSLocalizedString("gameover_correct_answers", comment: "Correct Answers"))
                    Spacer()
                    Text("\(viewModel.correctCount) / \(viewModel.totalQuestions)")
                        .font(.body.bold())
                        .foregroundColor(.green)
                }

                HStack {
                    Text(NSLocalizedString("gameover_wrong_missed", comment: "Wrong / Missed"))
                    Spacer()
                    Text("\(viewModel.wrongCount)")
                        .font(.body.bold())
                        .foregroundColor(.red)
                }
            }
            .padding(20)
            .background(FunColors.bgColor2)
            .cornerRadius(16)

            Spacer()

            // Bottom Action Buttons
            VStack(spacing: 12) {
                Button(action: {
                    viewModel.isGameOver = false
                    viewModel.startNewGame()
                }) {
                    Text(NSLocalizedString("gameover_play_again", comment: "Play Again"))
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .background(Color.blue)
                        .cornerRadius(14)
                }
                .buttonStyle(FunActionButtonStyle(cornerRadius: 14))

                Button(action: {
                    viewModel.isGameOver = false
                    dismissView()
                }) {
                    Text(NSLocalizedString("gameover_main_menu", comment: "Main Menu"))
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(14)
                }
                .buttonStyle(FunActionButtonStyle(cornerRadius: 14))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .padding(.horizontal, 20)
        .background(FunColors.bgColor.ignoresSafeArea())
    }

    private var gameOverTitle: String {
        switch viewModel.earnedStars {
        case 5: return NSLocalizedString("gameover_perfect", comment: "PERFECT!")
        case 4: return NSLocalizedString("gameover_great", comment: "GREAT JOB!")
        case 3: return NSLocalizedString("gameover_good", comment: "GOOD EFFORT!")
        case 2: return NSLocalizedString("gameover_practice", comment: "KEEP PRACTICING!")
        default: return NSLocalizedString("gameover_try_again", comment: "TRY AGAIN!")
        }
    }
}

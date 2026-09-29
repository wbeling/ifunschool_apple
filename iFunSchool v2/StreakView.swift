import SwiftUI

struct StreakView: View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var streakTracker = StreakTracker.shared
    @State private var refreshTrigger: Bool = false

    #if os(tvOS)
    private let columns = [GridItem(.adaptive(minimum: 140, maximum: 180), spacing: 18)]
    #else
    private let columns = [GridItem(.adaptive(minimum: 100, maximum: 130), spacing: 14)]
    #endif

    var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.title2)
                        .foregroundColor(.orange)
                    Text(LocalizedStringKey("nav_streak"))
                        .font(.title2.bold())
                }
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

            // Summary Header Card
            summaryHeaderCard
                .padding(.horizontal, 24)
                .padding(.vertical, 14)

            // Main Grid 1 to 30 Days
            ScrollView {
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(1...30, id: \.self) { day in
                        streakDayCell(day: day)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
        }
        .background(FunColors.bgColor.ignoresSafeArea())
        .onAppear {
            streakTracker.refreshStreakData()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("iFunSchoolStreakUpdated"))) { _ in
            refreshTrigger.toggle()
        }
        #if os(macOS)
        .frame(minWidth: 750, idealWidth: 900, minHeight: 600, idealHeight: 700)
        #elseif os(tvOS)
        .frame(minWidth: 1100, idealWidth: 1300, minHeight: 750, idealHeight: 850)
        #endif
    }

    // MARK: - Summary Header Card
    private var summaryHeaderCard: some View {
        _ = refreshTrigger
        let streak = streakTracker.streakCount
        let percent = Int((Double(streak) / 30.0) * 100.0)

        return VStack(spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(NSLocalizedString("streak_title", comment: "Dni z rzędu")): \(streak) / 30 (\(percent)%)")
                        .font(.headline.bold())
                        .foregroundColor(.primary)

                    Text(streakTracker.hasPlayedToday ? 
                         NSLocalizedString("streak_status_played_today", comment: "Dzień zaliczony! Wróć i zagraj innego dnia.") : 
                         NSLocalizedString("streak_status_need_play", comment: "Zagraj dzisiaj (min. 1 gwiazdka)!"))
                        .font(.subheadline)
                        .foregroundColor(streakTracker.hasPlayedToday ? .green : .orange)
                }

                Spacer()

                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.15))
                        .frame(width: 54, height: 54)
                    Image(systemName: "flame.fill")
                        .font(.title)
                        .foregroundColor(.orange)
                }
            }

            // Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.secondary.opacity(0.2))
                    Capsule().fill(
                        LinearGradient(
                            colors: [.orange, .yellow],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * CGFloat(streak) / 30.0)
                }
            }
            .frame(height: 10)
        }
        .padding(14)
        .background(Color.secondary.opacity(0.12))
        .cornerRadius(14)
    }

    // MARK: - Individual Day Grid Cell (1 to 30)
    private func streakDayCell(day: Int) -> some View {
        _ = refreshTrigger
        let streak = streakTracker.streakCount
        let hasPlayedToday = streakTracker.hasPlayedToday

        let isCompleted = day <= streak
        let isCurrentTarget = (!hasPlayedToday && day == streak + 1 && day <= 30)

        return Button(action: {}) {
            VStack(spacing: 6) {
                HStack {
                    Text("\(day)")
                        .font(.caption2.bold())
                        .foregroundColor(isCompleted ? .green : (isCurrentTarget ? .orange : .secondary))
                    Spacer()
                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else if isCurrentTarget {
                        Image(systemName: "smallcircle.filled.circle.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.caption2)
                            .foregroundColor(.gray.opacity(0.4))
                    }
                }

                Text("\(NSLocalizedString("streak_day_prefix", comment: "Dzień"))")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                Text("\(day)")
                    .font(.title2.bold())
                    .foregroundColor(isCompleted ? .primary : (isCurrentTarget ? .orange : .secondary))
            }
            .padding(10)
            .frame(minHeight: 80)
            .background(cellBackgroundColor(isCompleted: isCompleted, isCurrentTarget: isCurrentTarget))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(cellBorderColor(isCompleted: isCompleted, isCurrentTarget: isCurrentTarget), lineWidth: isCurrentTarget ? 2.5 : 1.5)
            )
        }
        .buttonStyle(FunActionButtonStyle())
    }

    private func cellBackgroundColor(isCompleted: Bool, isCurrentTarget: Bool) -> Color {
        if isCompleted {
            return Color.green.opacity(0.12)
        } else if isCurrentTarget {
            return Color.yellow.opacity(0.15)
        } else {
            return Color.secondary.opacity(0.06)
        }
    }

    private func cellBorderColor(isCompleted: Bool, isCurrentTarget: Bool) -> Color {
        if isCompleted {
            return Color.green.opacity(0.5)
        } else if isCurrentTarget {
            return Color.yellow
        } else {
            return Color.gray.opacity(0.2)
        }
    }
}

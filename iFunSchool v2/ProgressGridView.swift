import SwiftUI

enum ProgressCategory: String, CaseIterable, Identifiable {
    case addition = "Dodawanie"
    case subtraction = "Odejmowanie"
    case multiplication = "Mnożenie"
    case division = "Dzielenie"
    case flags = "Flagi"
    case elements = "Pierwiastki"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .addition: return NSLocalizedString("progress_cat_addition", comment: "Addition")
        case .subtraction: return NSLocalizedString("progress_cat_subtraction", comment: "Subtraction")
        case .multiplication: return NSLocalizedString("progress_cat_multiplication", comment: "Multiplication")
        case .division: return NSLocalizedString("progress_cat_division", comment: "Division")
        case .flags: return NSLocalizedString("progress_cat_flags", comment: "Flags")
        case .elements: return NSLocalizedString("progress_cat_elements", comment: "Elements")
        }
    }
}

enum ProgressFilter: String, CaseIterable, Identifiable {
    case all = "Wszystkie"
    case correct = "Poprawne"
    case incorrect = "Błędne"
    case notAsked = "Nieodpytane"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return NSLocalizedString("progress_filter_all", comment: "All")
        case .correct: return NSLocalizedString("progress_filter_correct", comment: "Correct")
        case .incorrect: return NSLocalizedString("progress_filter_incorrect", comment: "Incorrect")
        case .notAsked: return NSLocalizedString("progress_filter_not_asked", comment: "Not asked")
        }
    }
}

// MARK: - Focusable Grid Cell Button Style (tvOS Focus & Navigation Support)
#if os(tvOS)
struct ProgressGridCellButtonStyle: ButtonStyle {
    let status: ItemStatus
    @Environment(\.isFocused) private var isFocused
    @Environment(\.colorScheme) private var colorScheme

    func makeBody(configuration: Configuration) -> some View {
        let borderColor: Color = isFocused ? (colorScheme == .dark ? .white : .black) : Color.gray.opacity(0.35)
        configuration.label
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 1.0)
            )
            .scaleEffect(isFocused ? 1.04 : (configuration.isPressed ? 0.95 : 1.0))
            .animation(.easeInOut(duration: 0.15), value: isFocused)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
#else
struct ProgressGridCellButtonStyle: ButtonStyle {
    let status: ItemStatus

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(cardBorderColor(for: status), lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }

    private func cardBorderColor(for status: ItemStatus) -> Color {
        switch status {
        case .correct: return Color.green.opacity(0.4)
        case .incorrect: return Color.red.opacity(0.4)
        case .notAsked: return Color.gray.opacity(0.2)
        }
    }
}
#endif

struct ProgressGridView: View {
    @Environment(\.presentationMode) private var presentationMode
    @State private var selectedCategory: ProgressCategory
    @State private var selectedFilter: ProgressFilter = .all
    @State private var refreshTrigger: Bool = false

    private let generator = QuestionGenerator.shared

    #if os(tvOS)
    private let columns = [GridItem(.adaptive(minimum: 160, maximum: 200), spacing: 18)]
    #else
    private let columns = [GridItem(.adaptive(minimum: 120, maximum: 160), spacing: 14)]
    #endif

    init(initialCategory: ProgressCategory = .addition) {
        _selectedCategory = State(initialValue: initialCategory)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            HStack {
                Text(LocalizedStringKey("nav_progress"))
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

            // Category & Filter Selectors
            VStack(spacing: 12) {
                categoryChipsBar

                Picker("Filtr", selection: $selectedFilter) {
                    ForEach(ProgressFilter.allCases) { filter in
                        Text(filter.title).tag(filter)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 24)
            }
            .padding(.vertical, 12)

            // Summary Card
            summaryHeaderCard
                .padding(.horizontal, 24)

            // Main Content Grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 14) {
                    if selectedCategory == .flags {
                        ForEach(filteredFlagsItems, id: \.country) { item in
                            flagGridCell(item: item)
                        }
                    } else if selectedCategory == .elements {
                        ForEach(filteredElementsItems, id: \.element.symbol) { item in
                            elementGridCell(item: item)
                        }
                    } else {
                        ForEach(filteredMathItems, id: \.key) { item in
                            mathGridCell(item: item)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
            .id("\(selectedCategory.id)_\(selectedFilter.id)")
        }
        .background(FunColors.bgColor.ignoresSafeArea())
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("iFunSchoolItemProgressUpdated"))) { _ in
            refreshTrigger.toggle()
        }
        #if os(macOS)
        .frame(minWidth: 800, idealWidth: 950, minHeight: 650, idealHeight: 750)
        #elseif os(tvOS)
        .frame(minWidth: 1200, idealWidth: 1400, minHeight: 800, idealHeight: 900)
        #endif
    }

    // MARK: - Category Chips Bar
    private var categoryChipsBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ProgressCategory.allCases) { cat in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedCategory = cat
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: categoryIcon(for: cat))
                                .font(.subheadline)
                            Text(cat.title)
                                .font(.subheadline.bold())
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(selectedCategory == cat ? FunColors.chalkboardGreen : Color.secondary.opacity(0.12))
                        .foregroundColor(selectedCategory == cat ? .white : .primary)
                        .cornerRadius(20)
                    }
                    #if os(tvOS)
                    .buttonStyle(FunActionButtonStyle())
                    #else
                    .buttonStyle(.plain)
                    #endif
                    .accessibilityIdentifier("progress_cat_\(cat.rawValue)")
                }
            }
            .padding(.horizontal, 24)
        }
    }

    private func categoryIcon(for category: ProgressCategory) -> String {
        switch category {
        case .addition: return "plus.circle.fill"
        case .subtraction: return "minus.circle.fill"
        case .multiplication: return "multiply.circle.fill"
        case .division: return "divide.circle.fill"
        case .flags: return "flag.fill"
        case .elements: return "atom"
        }
    }

    // MARK: - Data Computations
    struct FlagProgressItem {
        let country: String
        let localizedName: String
        let flagAssetName: String
        let status: ItemStatus
    }

    struct ElementProgressItem {
        let element: ElementInfo
        let atomicNumber: Int
        let localizedName: String
        let status: ItemStatus
    }

    struct MathProgressItem {
        let key: String
        let expression: String
        let resultStr: String
        let status: ItemStatus
    }

    private var allFlagsItems: [FlagProgressItem] {
        _ = refreshTrigger
        return generator.allCountries.map { rawCountry in
            let itemKey = "country_\(rawCountry)"
            let status = ItemProgressTracker.shared.getStatus(for: itemKey)
            let localized = generator.localizedCountryName(for: rawCountry)
            let flagAsset = rawCountry.replacingOccurrences(of: " ", with: "_")
            return FlagProgressItem(country: rawCountry, localizedName: localized, flagAssetName: flagAsset, status: status)
        }
    }

    private var filteredFlagsItems: [FlagProgressItem] {
        switch selectedFilter {
        case .all: return allFlagsItems
        case .correct: return allFlagsItems.filter { $0.status == .correct }
        case .incorrect: return allFlagsItems.filter { $0.status == .incorrect }
        case .notAsked: return allFlagsItems.filter { $0.status == .notAsked }
        }
    }

    private var allElementsItems: [ElementProgressItem] {
        _ = refreshTrigger
        return generator.allElements.enumerated().map { index, elem in
            let itemKey = "chem_\(elem.symbol)"
            let status = ItemProgressTracker.shared.getStatus(for: itemKey)
            let localized = generator.localizedElementName(for: elem.name)
            return ElementProgressItem(element: elem, atomicNumber: index + 1, localizedName: localized, status: status)
        }
    }

    private var filteredElementsItems: [ElementProgressItem] {
        switch selectedFilter {
        case .all: return allElementsItems
        case .correct: return allElementsItems.filter { $0.status == .correct }
        case .incorrect: return allElementsItems.filter { $0.status == .incorrect }
        case .notAsked: return allElementsItems.filter { $0.status == .notAsked }
        }
    }

    private var currentMathItems: [MathProgressItem] {
        _ = refreshTrigger
        let keys: [String]
        switch selectedCategory {
        case .addition:
            keys = generator.itemKeysForLevel(gameType: .addition, level: .easy)
        case .subtraction:
            keys = generator.itemKeysForLevel(gameType: .subtraction, level: .easy)
        case .multiplication:
            keys = generator.itemKeysForLevel(gameType: .multiplication, level: .easy)
        case .division:
            keys = generator.itemKeysForLevel(gameType: .division, level: .easy)
        default:
            keys = []
        }

        let dict = ItemProgressTracker.shared.getProgressDict()

        return keys.map { key in
            let status = dict[key]?.status ?? .notAsked
            let parts = key.split(separator: "_")
            if parts.count >= 4, let a = Int(parts[2]), let b = Int(parts[3]) {
                let expr: String
                let res: String
                switch selectedCategory {
                case .addition:
                    expr = "\(a) + \(b)"
                    res = "\(a + b)"
                case .subtraction:
                    expr = "\(a) - \(b)"
                    res = "\(a - b)"
                case .multiplication:
                    expr = "\(a) × \(b)"
                    res = "\(a * b)"
                case .division:
                    expr = "\(a) ÷ \(b)"
                    res = "\(a / b)"
                default:
                    expr = "\(a) + \(b)"
                    res = "\(a + b)"
                }
                return MathProgressItem(key: key, expression: expr, resultStr: res, status: status)
            } else {
                return MathProgressItem(key: key, expression: key, resultStr: "", status: status)
            }
        }
    }

    private var filteredMathItems: [MathProgressItem] {
        switch selectedFilter {
        case .all: return currentMathItems
        case .correct: return currentMathItems.filter { $0.status == .correct }
        case .incorrect: return currentMathItems.filter { $0.status == .incorrect }
        case .notAsked: return currentMathItems.filter { $0.status == .notAsked }
        }
    }

    // MARK: - Summary Card
    private var summaryHeaderCard: some View {
        let total: Int
        let correctCount: Int
        let wrongCount: Int
        let notAskedCount: Int

        if selectedCategory == .flags {
            total = allFlagsItems.count
            correctCount = allFlagsItems.filter { $0.status == .correct }.count
            wrongCount = allFlagsItems.filter { $0.status == .incorrect }.count
            notAskedCount = allFlagsItems.filter { $0.status == .notAsked }.count
        } else if selectedCategory == .elements {
            total = allElementsItems.count
            correctCount = allElementsItems.filter { $0.status == .correct }.count
            wrongCount = allElementsItems.filter { $0.status == .incorrect }.count
            notAskedCount = allElementsItems.filter { $0.status == .notAsked }.count
        } else {
            total = currentMathItems.count
            correctCount = currentMathItems.filter { $0.status == .correct }.count
            wrongCount = currentMathItems.filter { $0.status == .incorrect }.count
            notAskedCount = currentMathItems.filter { $0.status == .notAsked }.count
        }

        let percent = total > 0 ? Int((Double(correctCount) / Double(total)) * 100.0) : 0

        return VStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(NSLocalizedString("progress_summary_total", comment: "Mastered")): \(correctCount) / \(total) (\(percent)%)")
                    .font(.headline.bold())
                    .foregroundColor(.primary)
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.secondary.opacity(0.2))
                        Capsule().fill(Color.green)
                            .frame(width: geo.size.width * CGFloat(correctCount) / CGFloat(max(1, total)))
                    }
                }
                .frame(height: 8)
            }

            HStack(spacing: 12) {
                statusBadgePill(count: correctCount, color: .green, iconName: "checkmark.circle.fill")
                statusBadgePill(count: wrongCount, color: .red, iconName: "xmark.circle.fill")
                statusBadgePill(count: notAskedCount, color: .gray, iconName: "questionmark.circle.fill")
            }
        }
        .padding(14)
        .background(Color.secondary.opacity(0.12))
        .cornerRadius(12)
    }

    private func statusBadgePill(count: Int, color: Color, iconName: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: iconName)
                .foregroundColor(color)
            Text("\(count)")
                .font(.subheadline.bold())
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.15))
        .cornerRadius(8)
    }

    // MARK: - Flag Grid Cell
    private func flagGridCell(item: FlagProgressItem) -> some View {
        Button(action: {}) {
            VStack(spacing: 6) {
                ZStack(alignment: .topTrailing) {
                    Image(item.flagAssetName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 48)
                        .cornerRadius(6)
                        .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)

                    statusIndicator(status: item.status)
                        .offset(x: 6, y: -6)
                }

                Text(item.localizedName)
                    .font(.caption.weight(.medium))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                    .frame(height: 32)
            }
            .padding(10)
            .background(cardBackgroundColor(for: item.status))
            .cornerRadius(12)
        }
        .buttonStyle(ProgressGridCellButtonStyle(status: item.status))
    }

    // MARK: - Element Grid Cell
    private func elementGridCell(item: ElementProgressItem) -> some View {
        Button(action: {}) {
            VStack(spacing: 4) {
                HStack {
                    Text("\(item.atomicNumber)")
                        .font(.caption2.bold())
                        .foregroundColor(.secondary)
                    Spacer()
                    statusIndicator(status: item.status)
                }

                Text(item.element.symbol)
                    .font(.title2.bold())
                    .foregroundColor(.primary)

                Text(item.localizedName)
                    .font(.caption.weight(.medium))
                    .lineLimit(1)
                    .foregroundColor(.secondary)
            }
            .padding(10)
            .background(cardBackgroundColor(for: item.status))
            .cornerRadius(12)
        }
        .buttonStyle(ProgressGridCellButtonStyle(status: item.status))
    }

    // MARK: - Math Grid Cell
    private func mathGridCell(item: MathProgressItem) -> some View {
        Button(action: {}) {
            VStack(spacing: 4) {
                HStack {
                    Spacer()
                    statusIndicator(status: item.status)
                }

                Text(item.expression)
                    .font(.title3.bold())
                    .foregroundColor(.primary)

                Text("= \(item.resultStr)")
                    .font(.caption.bold())
                    .foregroundColor(.secondary)
            }
            .padding(10)
            .frame(minHeight: 75)
            .background(cardBackgroundColor(for: item.status))
            .cornerRadius(12)
        }
        .buttonStyle(ProgressGridCellButtonStyle(status: item.status))
    }

    // MARK: - Status Indicators & Colors
    @ViewBuilder
    private func statusIndicator(status: ItemStatus) -> some View {
        switch status {
        case .correct:
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.caption)
        case .incorrect:
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.red)
                .font(.caption)
        case .notAsked:
            Image(systemName: "circle.fill")
                .foregroundColor(.gray.opacity(0.4))
                .font(.caption2)
        }
    }

    private func cardBackgroundColor(for status: ItemStatus) -> Color {
        switch status {
        case .correct: return Color.green.opacity(0.08)
        case .incorrect: return Color.red.opacity(0.08)
        case .notAsked: return Color.secondary.opacity(0.06)
        }
    }

    private func cardBorderColor(for status: ItemStatus) -> Color {
        switch status {
        case .correct: return Color.green.opacity(0.4)
        case .incorrect: return Color.red.opacity(0.4)
        case .notAsked: return Color.gray.opacity(0.2)
        }
    }
}

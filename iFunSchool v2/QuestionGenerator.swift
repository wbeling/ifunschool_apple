import Foundation

struct MemoryGridItem: Identifiable, Equatable {
    let id = UUID()
    let shapeSymbol: String
    let colorName: String
}

struct Question {
    let id = UUID()
    let itemKey: String
    let text: String
    let subtext: String?
    let options: [String]
    let correctIndex: Int
    let maxTime: Double
    let flagImageName: String?
    let memorySteps: [String]?
    let memoryGridItems: [MemoryGridItem]?
    let memoryPreviewSeconds: Double?

    init(
        itemKey: String = "",
        text: String,
        subtext: String? = nil,
        options: [String],
        correctIndex: Int,
        maxTime: Double,
        flagImageName: String? = nil,
        memorySteps: [String]? = nil,
        memoryGridItems: [MemoryGridItem]? = nil,
        memoryPreviewSeconds: Double? = nil
    ) {
        self.itemKey = itemKey
        self.text = text
        self.subtext = subtext
        self.options = options
        self.correctIndex = correctIndex
        self.maxTime = maxTime
        self.flagImageName = flagImageName
        self.memorySteps = memorySteps
        self.memoryGridItems = memoryGridItems
        self.memoryPreviewSeconds = memoryPreviewSeconds
    }
}

struct ElementInfo {
    let symbol: String
    let name: String
}

class QuestionGenerator {
    static let shared = QuestionGenerator()

    // Complete 118 periodic table elements
    private(set) var allElements: [ElementInfo] = [
        ElementInfo(symbol: "H", name: "Hydrogen"), ElementInfo(symbol: "He", name: "Helium"),
        ElementInfo(symbol: "Li", name: "Lithium"), ElementInfo(symbol: "Be", name: "Beryllium"),
        ElementInfo(symbol: "B", name: "Boron"), ElementInfo(symbol: "C", name: "Carbon"),
        ElementInfo(symbol: "N", name: "Nitrogen"), ElementInfo(symbol: "O", name: "Oxygen"),
        ElementInfo(symbol: "F", name: "Fluorine"), ElementInfo(symbol: "Ne", name: "Neon"),
        ElementInfo(symbol: "Na", name: "Sodium"), ElementInfo(symbol: "Mg", name: "Magnesium"),
        ElementInfo(symbol: "Al", name: "Aluminum"), ElementInfo(symbol: "Si", name: "Silicon"),
        ElementInfo(symbol: "P", name: "Phosphorus"), ElementInfo(symbol: "S", name: "Sulfur"),
        ElementInfo(symbol: "Cl", name: "Chlorine"), ElementInfo(symbol: "Ar", name: "Argon"),
        ElementInfo(symbol: "K", name: "Potassium"), ElementInfo(symbol: "Ca", name: "Calcium"),
        ElementInfo(symbol: "Sc", name: "Scandium"), ElementInfo(symbol: "Ti", name: "Titanium"),
        ElementInfo(symbol: "V", name: "Vanadium"), ElementInfo(symbol: "Cr", name: "Chromium"),
        ElementInfo(symbol: "Mn", name: "Manganese"), ElementInfo(symbol: "Fe", name: "Iron"),
        ElementInfo(symbol: "Co", name: "Cobalt"), ElementInfo(symbol: "Ni", name: "Nickel"),
        ElementInfo(symbol: "Cu", name: "Copper"), ElementInfo(symbol: "Zn", name: "Zinc"),
        ElementInfo(symbol: "Ga", name: "Gallium"), ElementInfo(symbol: "Ge", name: "Germanium"),
        ElementInfo(symbol: "As", name: "Arsenic"), ElementInfo(symbol: "Se", name: "Selenium"),
        ElementInfo(symbol: "Br", name: "Bromine"), ElementInfo(symbol: "Kr", name: "Krypton"),
        ElementInfo(symbol: "Rb", name: "Rubidium"), ElementInfo(symbol: "Sr", name: "Strontium"),
        ElementInfo(symbol: "Y", name: "Yttrium"), ElementInfo(symbol: "Zr", name: "Zirconium"),
        ElementInfo(symbol: "Nb", name: "Niobium"), ElementInfo(symbol: "Mo", name: "Molybdenum"),
        ElementInfo(symbol: "Tc", name: "Technetium"), ElementInfo(symbol: "Ru", name: "Ruthenium"),
        ElementInfo(symbol: "Rh", name: "Rhodium"), ElementInfo(symbol: "Pd", name: "Palladium"),
        ElementInfo(symbol: "Ag", name: "Silver"), ElementInfo(symbol: "Cd", name: "Cadmium"),
        ElementInfo(symbol: "In", name: "Indium"), ElementInfo(symbol: "Sn", name: "Tin"),
        ElementInfo(symbol: "Sb", name: "Antimony"), ElementInfo(symbol: "Te", name: "Tellurium"),
        ElementInfo(symbol: "I", name: "Iodine"), ElementInfo(symbol: "Xe", name: "Xenon"),
        ElementInfo(symbol: "Cs", name: "Cesium"), ElementInfo(symbol: "Ba", name: "Barium"),
        ElementInfo(symbol: "La", name: "Lanthanum"), ElementInfo(symbol: "Ce", name: "Cerium"),
        ElementInfo(symbol: "Pr", name: "Praseodymium"), ElementInfo(symbol: "Nd", name: "Neodymium"),
        ElementInfo(symbol: "Pm", name: "Promethium"), ElementInfo(symbol: "Sm", name: "Samarium"),
        ElementInfo(symbol: "Eu", name: "Europium"), ElementInfo(symbol: "Gd", name: "Gadolinium"),
        ElementInfo(symbol: "Tb", name: "Terbium"), ElementInfo(symbol: "Dy", name: "Dysprosium"),
        ElementInfo(symbol: "Ho", name: "Holmium"), ElementInfo(symbol: "Er", name: "Erbium"),
        ElementInfo(symbol: "Tm", name: "Thulium"), ElementInfo(symbol: "Yb", name: "Ytterbium"),
        ElementInfo(symbol: "Lu", name: "Lutetium"), ElementInfo(symbol: "Hf", name: "Hafnium"),
        ElementInfo(symbol: "Ta", name: "Tantalum"), ElementInfo(symbol: "W", name: "Tungsten"),
        ElementInfo(symbol: "Re", name: "Rhenium"), ElementInfo(symbol: "Os", name: "Osmium"),
        ElementInfo(symbol: "Ir", name: "Iridium"), ElementInfo(symbol: "Pt", name: "Platinum"),
        ElementInfo(symbol: "Au", name: "Gold"), ElementInfo(symbol: "Hg", name: "Mercury"),
        ElementInfo(symbol: "Tl", name: "Thallium"), ElementInfo(symbol: "Pb", name: "Lead"),
        ElementInfo(symbol: "Bi", name: "Bismuth"), ElementInfo(symbol: "Po", name: "Polonium"),
        ElementInfo(symbol: "At", name: "Astatine"), ElementInfo(symbol: "Rn", name: "Radon"),
        ElementInfo(symbol: "Fr", name: "Francium"), ElementInfo(symbol: "Ra", name: "Radium"),
        ElementInfo(symbol: "Ac", name: "Actinium"), ElementInfo(symbol: "Th", name: "Thorium"),
        ElementInfo(symbol: "Pa", name: "Protactinium"), ElementInfo(symbol: "U", name: "Uranium"),
        ElementInfo(symbol: "Np", name: "Neptunium"), ElementInfo(symbol: "Pu", name: "Plutonium"),
        ElementInfo(symbol: "Am", name: "Americium"), ElementInfo(symbol: "Cm", name: "Curium"),
        ElementInfo(symbol: "Bk", name: "Berkelium"), ElementInfo(symbol: "Cf", name: "Californium"),
        ElementInfo(symbol: "Es", name: "Einsteinium"), ElementInfo(symbol: "Fm", name: "Fermium"),
        ElementInfo(symbol: "Md", name: "Mendelevium"), ElementInfo(symbol: "No", name: "Nobelium"),
        ElementInfo(symbol: "Lr", name: "Lawrencium"), ElementInfo(symbol: "Rf", name: "Rutherfordium"),
        ElementInfo(symbol: "Db", name: "Dubnium"), ElementInfo(symbol: "Sg", name: "Seaborgium"),
        ElementInfo(symbol: "Bh", name: "Bohrium"), ElementInfo(symbol: "Hs", name: "Hassium"),
        ElementInfo(symbol: "Mt", name: "Meitnerium"), ElementInfo(symbol: "Ds", name: "Darmstadtium"),
        ElementInfo(symbol: "Rg", name: "Roentgenium"), ElementInfo(symbol: "Cn", name: "Copernicium"),
        ElementInfo(symbol: "Uut", name: "Nihonium"), ElementInfo(symbol: "Uuq", name: "Flerovium"),
        ElementInfo(symbol: "Uup", name: "Moscovium"), ElementInfo(symbol: "Uuh", name: "Livermorium"),
        ElementInfo(symbol: "Uus", name: "Tennessine"), ElementInfo(symbol: "Uuo", name: "Oganesson")
    ]
    // Complete 203-country list from panstwa.dat
    private(set) var allCountries: [String] = [
        "People's Republic of China", "India", "United States", "Indonesia", "Brazil", "Pakistan", "Nigeria", "Russia", "Japan", "Mexico",
        "Philippines", "Vietnam", "Germany", "Egypt", "Ethiopia", "Iran", "Turkey", "France", "United Kingdom", "Italy",
        "South Africa", "South Korea", "Spain", "Colombia", "Poland", "Australia", "Austria", "Belgium", "Bosnia and Herzegovina", "Chile",
        "Croatia", "Cuba", "Cyprus", "Czech Republic", "Estonia", "Finland", "Hungary", "Iceland", "Iraq", "Ireland",
        "Israel", "Luxembourg", "Macedonia", "Portugal", "Slovakia", "Slovenia", "Ukraine", "Vatican City", "Zimbabwe", "Sudan",
        "Algeria", "Canada", "Morocco", "Abkhazia", "Afghanistan", "Albania", "Andorra", "Angola", "Antigua and Barbuda", "Argentina",
        "Armenia", "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belize", "Benin", "Bhutan",
        "Bolivia", "Botswana", "Brunei", "Bulgaria", "Burkina Faso", "Burundi", "Cambodia", "Cameroon", "Cape Verde", "Central African Republic",
        "Chad", "Comoros", "Costa Rica", "Cote d'Ivoire", "Democratic Republic of the Congo", "Denmark", "Djibouti", "Dominica", "Dominican Republic", "East Timor",
        "Ecuador", "El Salvador", "Equatorial Guinea", "Eritrea", "Federated States of Micronesia", "Fiji", "Gabon", "Gambia", "Georgia", "Ghana",
        "Greece", "Grenada", "Guatemala", "Guinea", "Guinea-Bissau", "Guyana", "Haiti", "Honduras", "Jamaica", "Jordan",
        "Kazakhstan", "Kenya", "Kiribati", "Kosovo", "Kuwait", "Kyrgyzstan", "Laos", "Latvia", "Lebanon", "Lesotho",
        "Liberia", "Libya", "Liechtenstein", "Lithuania", "Madagascar", "Malawi", "Malaysia", "Maldives", "Mali", "Malta",
        "Marshall Islands", "Mauritania", "Mauritius", "Moldova", "Monaco", "Mongolia", "Montenegro", "Mozambique", "Myanmar", "Nagorno-Karabakh",
        "Namibia", "Nauru", "Nepal", "Netherlands", "New Zealand", "Nicaragua", "Niger", "North Korea", "Norway", "Oman",
        "Palau", "Palestine", "Panama", "Papua New Guinea", "Paraguay", "Peru", "Qatar", "Republic of China", "Republic of the Congo", "Romania",
        "Rwanda", "Saint Kitts and Nevis", "Saint Lucia", "Saint Vincent and the Grenadines", "Samoa", "San Marino", "Sao Tome and Principe", "Saudi Arabia", "Senegal", "Serbia",
        "Seychelles", "Sierra Leone", "Singapore", "Solomon Islands", "Somalia", "Somaliland", "South Ossetia", "Sri Lanka", "Suriname", "Swaziland",
        "Sweden", "Switzerland", "Syria", "Tajikistan", "Tanzania", "Thailand", "Togo", "Tonga", "Transnistria", "Trinidad and Tobago",
        "Tunisia", "Turkish Republic of Northern Cyprus", "Turkmenistan", "Tuvalu", "Uganda", "United Arab Emirates", "Uruguay", "Uzbekistan", "Vanuatu", "Venezuela",
        "Western Sahara", "Yemen", "Zambia"
    ]

    init() {
        loadPanstwaFromFile()
    }

    func localizedCountryName(for englishName: String) -> String {
        let key = "country_\(englishName)"
        let localized = NSLocalizedString(key, comment: "")
        if localized != key {
            return localized
        }
        return englishName
    }

    func localizedElementName(for englishName: String) -> String {
        let key = "element_\(englishName)"
        let localized = NSLocalizedString(key, comment: "")
        if localized != key {
            return localized
        }
        return englishName
    }

    private func loadPanstwaFromFile() {
        if let path = Bundle.main.path(forResource: "panstwa", ofType: "dat"),
           let content = try? String(contentsOfFile: path, encoding: .utf8) {
            let loaded = content.components(separatedBy: .newlines)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            if !loaded.isEmpty {
                self.allCountries = loaded
            }
        }
    }

    func getMaxTime(for level: GameLevel) -> Double {
        switch level {
        case .beginner: return 20.0
        case .easy: return 25.0
        case .medium: return 30.0
        case .hard: return 35.0
        case .ultimate: return 40.0
        case .godlike: return 45.0
        }
    }

    func TotalQuestions(for level: GameLevel) -> Int {
        return 15
    }

    func scoreMultiplier(for level: GameLevel) -> Double {
        switch level {
        case .beginner: return 1.0
        case .easy: return 20.0 / 15.0      // 1.3333x
        case .medium: return 25.0 / 15.0    // 1.6667x
        case .hard: return 30.0 / 15.0      // 2.0x
        case .ultimate: return 35.0 / 15.0  // 2.3333x
        case .godlike: return 40.0 / 15.0   // 2.6667x
        }
    }

    func generateQuestion(gameType: GameType, level: GameLevel) -> Question {
        let time = getMaxTime(for: level)

        switch gameType {
        case .addition:
            return generateAddition(level: level, maxTime: time)
        case .subtraction:
            return generateSubtraction(level: level, maxTime: time)
        case .multiplication:
            return generateMultiplication(level: level, maxTime: time)
        case .division:
            return generateDivision(level: level, maxTime: time)
        case .order:
            return generateOrderOfOperations(level: level, maxTime: time)
        case .sequences:
            return generateSequences(level: level, maxTime: time)
        case .equations:
            return generateEquations(level: level, maxTime: time)
        case .memoryAdd:
            return generateMemoryAdd(level: level, maxTime: time)
        case .memoryAddSub:
            return generateMemoryAddSub(level: level, maxTime: time)
        case .memoryAddSubMult:
            return generateMemoryAddSubMult(level: level, maxTime: time)
        case .memoryShapes:
            return generateMemoryShapes(level: level, maxTime: time)
        case .memoryColors:
            return generateMemoryColors(level: level, maxTime: time)
        case .chemSymbols:
            return generateChemSymbols(level: level, maxTime: time)
        case .chemNames:
            return generateChemNames(level: level, maxTime: time)
        case .flags:
            return generateFlags(level: level, maxTime: time)
        }
    }

    // Helper for chemical elements range index selection matching MathGenerator.m
    private func selectElementIndex(level: GameLevel) -> Int {
        let total = allElements.count
        guard total > 0 else { return 0 }

        switch level {
        case .beginner:
            return Int.random(in: 0..<min(25, total))
        case .easy:
            return Int.random(in: 0..<min(50, total))
        case .medium:
            return Int.random(in: min(20, total - 1)..<min(70, total))
        case .hard:
            return Int.random(in: min(40, total - 1)..<min(90, total))
        case .ultimate:
            return Int.random(in: min(60, total - 1)..<min(110, total))
        case .godlike:
            return Int.random(in: min(65, total - 1)..<total)
        }
    }

    // MARK: - 1. Addition
    private func generateAddition(level: GameLevel, maxTime: Double) -> Question {
        let (r1, r2): (Int, Int)
        switch level {
        case .beginner:
            r1 = Int.random(in: 1...9)
            r2 = Int.random(in: 2...9)
        case .easy:
            r1 = Int.random(in: 1...19)
            r2 = Int.random(in: 2...18)
        case .medium:
            let total = Int.random(in: 20...100)
            r1 = Int.random(in: 10...(total - 10))
            r2 = total - r1
        case .hard:
            let total = Int.random(in: 100...200)
            r1 = Int.random(in: 50...(total - 50))
            r2 = total - r1
        default:
            let total = Int.random(in: 200...1000)
            r1 = Int.random(in: 100...(total - 100))
            r2 = total - r1
        }

        let correct = r1 + r2
        let text = "\(r1) + \(r2)"
        let options = makeNumericOptions(correct: correct, range: 10)
        let correctIdx = options.firstIndex(of: "\(correct)") ?? 0

        return Question(text: text, subtext: NSLocalizedString("prompt_calc_sum", comment: "Calculate sum"), options: options, correctIndex: correctIdx, maxTime: maxTime, flagImageName: nil, memorySteps: nil, memoryGridItems: nil, memoryPreviewSeconds: nil)
    }

    // MARK: - 2. Subtraction
    private func generateSubtraction(level: GameLevel, maxTime: Double) -> Question {
        let (r1, r2): (Int, Int)
        switch level {
        case .beginner:
            r2 = Int.random(in: 1...10)
            let diff = Int.random(in: 1...10)
            r1 = r2 + diff
        case .easy:
            r2 = Int.random(in: 10...30)
            let diff = Int.random(in: 1...20)
            r1 = r2 + diff
        case .medium:
            r2 = Int.random(in: 10...40)
            let diff = Int.random(in: 10...40)
            r1 = r2 + diff
        default:
            r2 = Int.random(in: 50...150)
            let diff = Int.random(in: 20...100)
            r1 = r2 + diff
        }

        let correct = r1 - r2
        let text = "\(r1) - \(r2)"
        let options = makeNumericOptions(correct: correct, range: 12)
        let correctIdx = options.firstIndex(of: "\(correct)") ?? 0

        return Question(text: text, subtext: NSLocalizedString("prompt_calc_diff", comment: "Calculate difference"), options: options, correctIndex: correctIdx, maxTime: maxTime, flagImageName: nil, memorySteps: nil, memoryGridItems: nil, memoryPreviewSeconds: nil)
    }

    // MARK: - 3. Multiplication
    private func generateMultiplication(level: GameLevel, maxTime: Double) -> Question {
        let (r1, r2): (Int, Int)
        switch level {
        case .beginner:
            r1 = Int.random(in: 2...9)
            r2 = Int.random(in: 2...9)
        case .easy:
            r1 = Int.random(in: 3...9)
            r2 = Int.random(in: 11...19)
        case .medium:
            r1 = Int.random(in: 11...25)
            r2 = Int.random(in: 11...25)
        default:
            r1 = Int.random(in: 20...50)
            r2 = Int.random(in: 15...30)
        }

        let correct = r1 * r2
        let text = "\(r1) × \(r2)"
        let options = makeNumericOptions(correct: correct, range: 15)
        let correctIdx = options.firstIndex(of: "\(correct)") ?? 0

        return Question(text: text, subtext: NSLocalizedString("prompt_calc_product", comment: "Calculate product"), options: options, correctIndex: correctIdx, maxTime: maxTime, flagImageName: nil, memorySteps: nil, memoryGridItems: nil, memoryPreviewSeconds: nil)
    }

    // MARK: - 4. Division
    private func generateDivision(level: GameLevel, maxTime: Double) -> Question {
        let (divisor, quotient): (Int, Int)
        switch level {
        case .beginner:
            divisor = Int.random(in: 2...9)
            quotient = Int.random(in: 1...10)
        case .easy:
            divisor = Int.random(in: 3...10)
            quotient = Int.random(in: 10...20)
        case .medium:
            divisor = Int.random(in: 10...30)
            quotient = Int.random(in: 10...25)
        default:
            divisor = Int.random(in: 15...40)
            quotient = Int.random(in: 15...35)
        }

        let dividend = divisor * quotient
        let text = "\(dividend) ÷ \(divisor)"
        let options = makeNumericOptions(correct: quotient, range: 8)
        let correctIdx = options.firstIndex(of: "\(quotient)") ?? 0

        return Question(text: text, subtext: NSLocalizedString("prompt_calc_quotient", comment: "Calculate quotient"), options: options, correctIndex: correctIdx, maxTime: maxTime, flagImageName: nil, memorySteps: nil, memoryGridItems: nil, memoryPreviewSeconds: nil)
    }

    // MARK: - 5. Order of Operations
    private func generateOrderOfOperations(level: GameLevel, maxTime: Double) -> Question {
        let r1 = Int.random(in: 2...10)
        let r2 = Int.random(in: 2...8)
        let r3 = Int.random(in: 2...8)

        let variant = Int.random(in: 0...2)
        let text: String
        let correct: Int

        switch variant {
        case 0:
            text = "\(r1) + \(r2) × \(r3)"
            correct = r1 + (r2 * r3)
        case 1:
            text = "\(r2) × \(r3) + \(r1)"
            correct = (r2 * r3) + r1
        default:
            let r4 = Int.random(in: 2...10)
            text = "\(r1) + \(r2) × \(r3) + \(r4)"
            correct = r1 + (r2 * r3) + r4
        }

        let options = makeNumericOptions(correct: correct, range: 12)
        let correctIdx = options.firstIndex(of: "\(correct)") ?? 0

        return Question(text: text, subtext: NSLocalizedString("prompt_operator_precedence", comment: "Operator precedence"), options: options, correctIndex: correctIdx, maxTime: maxTime, flagImageName: nil, memorySteps: nil, memoryGridItems: nil, memoryPreviewSeconds: nil)
    }

    // MARK: - 6. Sequences
    private func generateSequences(level: GameLevel, maxTime: Double) -> Question {
        let start = Int.random(in: 2...20)
        let step = Int.random(in: 2...8)
        let missingPos = Int.random(in: 0...3)

        let seq = [start, start + step, start + (step * 2), start + (step * 3)]
        let correct = seq[missingPos]

        var textParts: [String] = []
        for i in 0..<4 {
            if i == missingPos {
                textParts.append("?")
            } else {
                textParts.append("\(seq[i])")
            }
        }

        let text = textParts.joined(separator: ", ")
        let options = makeNumericOptions(correct: correct, range: step * 2)
        let correctIdx = options.firstIndex(of: "\(correct)") ?? 0

        return Question(text: text, subtext: NSLocalizedString("prompt_missing_seq", comment: "Missing sequence number"), options: options, correctIndex: correctIdx, maxTime: maxTime, flagImageName: nil, memorySteps: nil, memoryGridItems: nil, memoryPreviewSeconds: nil)
    }

    // MARK: - 7. Equations
    private func generateEquations(level: GameLevel, maxTime: Double) -> Question {
        let a = Int.random(in: 2...8)
        let b = Int.random(in: 2...6)
        let c = Int.random(in: 2...10)
        
        let correctX = b * a + c
        let text = "y = \(a);  x = \(b)y + \(c)"

        let options = makeNumericOptions(correct: correctX, range: 10)
        let correctIdx = options.firstIndex(of: "\(correctX)") ?? 0

        return Question(text: text, subtext: NSLocalizedString("prompt_find_x", comment: "Find value of x"), options: options, correctIndex: correctIdx, maxTime: maxTime, flagImageName: nil, memorySteps: nil, memoryGridItems: nil, memoryPreviewSeconds: nil)
    }

    // MARK: - 8. Memory Addition
    private func generateMemoryAdd(level: GameLevel, maxTime: Double) -> Question {
        let stepCount: Int
        switch level {
        case .beginner: stepCount = 3
        case .easy: stepCount = 4
        case .medium: stepCount = 5
        case .hard: stepCount = 6
        default: stepCount = 7
        }

        let first = Int.random(in: 2...12)
        var steps = ["\(first)"]
        var currentSum = first
        var lastAddedVal: Int? = nil

        for _ in 1..<stepCount {
            var nextVal = Int.random(in: 2...10)
            while nextVal == lastAddedVal {
                nextVal = Int.random(in: 2...10)
            }
            lastAddedVal = nextVal
            currentSum += nextVal
            steps.append("+\(nextVal)")
        }

        let options = makeNumericOptions(correct: currentSum, range: 10)
        let correctIdx = options.firstIndex(of: "\(currentSum)") ?? 0

        return Question(
            text: NSLocalizedString("prompt_memory_math_final", comment: "Final result"),
            subtext: NSLocalizedString("prompt_memory_math_subtext", comment: "Remember operations"),
            options: options,
            correctIndex: correctIdx,
            maxTime: maxTime,
            flagImageName: nil,
            memorySteps: steps,
            memoryGridItems: nil,
            memoryPreviewSeconds: nil
        )
    }

    // MARK: - 9. Memory Add & Subtract
    private func generateMemoryAddSub(level: GameLevel, maxTime: Double) -> Question {
        let stepCount: Int
        switch level {
        case .beginner: stepCount = 3
        case .easy: stepCount = 4
        case .medium: stepCount = 5
        case .hard: stepCount = 6
        default: stepCount = 7
        }

        let first = Int.random(in: 10...25)
        var steps = ["\(first)"]
        var currentVal = first
        var lastStepString: String? = nil

        for _ in 1..<stepCount {
            let isAdd: Bool
            if currentVal <= 2 {
                isAdd = true
            } else {
                isAdd = Bool.random()
            }

            var delta: Int
            var stepString: String

            if isAdd {
                delta = Int.random(in: 2...10)
                stepString = "+\(delta)"
                while stepString == lastStepString {
                    delta = Int.random(in: 2...10)
                    stepString = "+\(delta)"
                }
                currentVal += delta
            } else {
                let maxSub = min(10, currentVal - 1)
                if maxSub >= 2 {
                    delta = Int.random(in: 2...maxSub)
                } else {
                    delta = 1
                }
                stepString = "-\(delta)"
                if stepString == lastStepString {
                    let availableDeltas = (2...max(2, maxSub)).filter { "-\($0)" != lastStepString }
                    if let newDelta = availableDeltas.randomElement() {
                        delta = newDelta
                        stepString = "-\(delta)"
                        currentVal -= delta
                    } else {
                        delta = Int.random(in: 2...10)
                        stepString = "+\(delta)"
                        currentVal += delta
                    }
                } else {
                    currentVal -= delta
                }
            }

            lastStepString = stepString
            steps.append(stepString)
        }

        let options = makeNumericOptions(correct: currentVal, range: 10)
        let correctIdx = options.firstIndex(of: "\(currentVal)") ?? 0

        return Question(
            text: NSLocalizedString("prompt_memory_math_final", comment: "Final result"),
            subtext: NSLocalizedString("prompt_memory_math_subtext", comment: "Remember operations"),
            options: options,
            correctIndex: correctIdx,
            maxTime: maxTime,
            flagImageName: nil,
            memorySteps: steps,
            memoryGridItems: nil,
            memoryPreviewSeconds: nil
        )
    }

    // MARK: - 10. Memory Math Operations
    private func generateMemoryAddSubMult(level: GameLevel, maxTime: Double) -> Question {
        let stepCount: Int
        switch level {
        case .beginner: stepCount = 3
        case .easy: stepCount = 4
        case .medium: stepCount = 5
        case .hard: stepCount = 6
        default: stepCount = 7
        }

        let first = Int.random(in: 2...8)
        var steps = ["\(first)"]
        var currentVal = first
        var lastStepString: String? = nil

        for i in 1..<stepCount {
            var opString = ""
            var attempts = 0
            while attempts < 20 {
                attempts += 1
                let choice: Int
                if i == 1 && Bool.random() {
                    choice = 0
                } else if currentVal <= 2 {
                    choice = 1
                } else {
                    choice = Int.random(in: 0...2)
                }

                var tempVal = currentVal
                var candidateStr = ""

                switch choice {
                case 0:
                    let mult = Int.random(in: 2...4)
                    candidateStr = "×\(mult)"
                    tempVal *= mult
                case 1:
                    let delta = Int.random(in: 2...8)
                    candidateStr = "+\(delta)"
                    tempVal += delta
                default:
                    let maxSub = min(8, currentVal - 1)
                    if maxSub >= 2 {
                        let delta = Int.random(in: 2...maxSub)
                        candidateStr = "-\(delta)"
                        tempVal -= delta
                    } else {
                        candidateStr = "-1"
                        tempVal -= 1
                    }
                }

                if candidateStr != lastStepString && tempVal >= 1 {
                    opString = candidateStr
                    currentVal = tempVal
                    break
                }
            }

            if opString.isEmpty {
                var delta = Int.random(in: 2...8)
                while "+\(delta)" == lastStepString {
                    delta += 1
                }
                opString = "+\(delta)"
                currentVal += delta
            }

            lastStepString = opString
            steps.append(opString)
        }

        let options = makeNumericOptions(correct: currentVal, range: 12)
        let correctIdx = options.firstIndex(of: "\(currentVal)") ?? 0

        return Question(
            text: NSLocalizedString("prompt_memory_math_final", comment: "Final result"),
            subtext: NSLocalizedString("prompt_memory_math_subtext", comment: "Remember operations"),
            options: options,
            correctIndex: correctIdx,
            maxTime: maxTime,
            flagImageName: nil,
            memorySteps: steps,
            memoryGridItems: nil,
            memoryPreviewSeconds: nil
        )
    }

    // MARK: - 11. Memory Shapes (ALL figures in SAME uniform color)
    private func generateMemoryShapes(level: GameLevel, maxTime: Double) -> Question {
        let shapes = ["square.fill", "circle.fill", "triangle.fill", "diamond.fill", "star.fill"]
        let targetShape = shapes.randomElement() ?? "circle.fill"
        
        let uniformColor = ["BLUE", "PURPLE", "ORANGE", "GREEN"].randomElement() ?? "BLUE"

        let gridCount: Int
        let previewSecs: Double
        switch level {
        case .beginner: gridCount = 6; previewSecs = 6.0
        case .easy: gridCount = 8; previewSecs = 7.0
        case .medium: gridCount = 10; previewSecs = 8.0
        case .hard: gridCount = 12; previewSecs = 9.0
        default: gridCount = 15; previewSecs = 10.0
        }

        var items: [MemoryGridItem] = []
        var targetCount = 0
        for _ in 0..<gridCount {
            if let shape = shapes.randomElement() {
                items.append(MemoryGridItem(shapeSymbol: shape, colorName: uniformColor))
                if shape == targetShape {
                    targetCount += 1
                }
            }
        }

        let shapeNameKey: String
        switch targetShape {
        case "square.fill": shapeNameKey = "shape_squares"
        case "circle.fill": shapeNameKey = "shape_circles"
        case "triangle.fill": shapeNameKey = "shape_triangles"
        case "diamond.fill": shapeNameKey = "shape_diamonds"
        default: shapeNameKey = "shape_stars"
        }

        let options = makeNumericOptions(correct: targetCount, range: 4, minVal: 0, maxVal: gridCount)
        let correctIdx = options.firstIndex(of: "\(targetCount)") ?? 0

        let localizedShapeName = NSLocalizedString(shapeNameKey, comment: "Shape name")
        let formatStr = NSLocalizedString("prompt_memory_shapes_count_format", comment: "How many shapes")
        let promptText = String(format: formatStr, localizedShapeName)

        return Question(
            text: promptText,
            subtext: NSLocalizedString("prompt_memory_shapes_subtext", comment: "Memorize grid"),
            options: options,
            correctIndex: correctIdx,
            maxTime: maxTime,
            flagImageName: nil,
            memorySteps: nil,
            memoryGridItems: items,
            memoryPreviewSeconds: previewSecs
        )
    }

    // MARK: - 12. Memory Colors (Figures in DIFFERENT vibrant colors)
    private func generateMemoryColors(level: GameLevel, maxTime: Double) -> Question {
        let colors = ["RED", "BLUE", "GREEN", "YELLOW", "PURPLE", "ORANGE"]
        let targetColor = colors.randomElement() ?? "RED"
        let shapes = ["square.fill", "circle.fill", "triangle.fill", "star.fill"]

        let gridCount: Int
        let previewSecs: Double
        switch level {
        case .beginner: gridCount = 6; previewSecs = 6.0
        case .easy: gridCount = 8; previewSecs = 7.0
        case .medium: gridCount = 10; previewSecs = 8.0
        case .hard: gridCount = 12; previewSecs = 9.0
        default: gridCount = 15; previewSecs = 10.0
        }

        var items: [MemoryGridItem] = []
        var targetCount = 0
        for _ in 0..<gridCount {
            if let color = colors.randomElement(), let shape = shapes.randomElement() {
                items.append(MemoryGridItem(shapeSymbol: shape, colorName: color))
                if color == targetColor {
                    targetCount += 1
                }
            }
        }

        let options = makeNumericOptions(correct: targetCount, range: 4, minVal: 0, maxVal: gridCount)
        let correctIdx = options.firstIndex(of: "\(targetCount)") ?? 0

        let colorKey: String
        switch targetColor {
        case "RED": colorKey = "color_red"
        case "BLUE": colorKey = "color_blue"
        case "GREEN": colorKey = "color_green"
        case "YELLOW": colorKey = "color_yellow"
        case "PURPLE": colorKey = "color_purple"
        case "ORANGE": colorKey = "color_orange"
        default: colorKey = "color_red"
        }

        let localizedColorName = NSLocalizedString(colorKey, comment: "Color name")
        let formatStr = NSLocalizedString("prompt_memory_colors_count_format", comment: "How many color items")
        let promptText = String(format: formatStr, localizedColorName)

        return Question(
            text: promptText,
            subtext: NSLocalizedString("prompt_memory_colors_subtext", comment: "Memorize colors grid"),
            options: options,
            correctIndex: correctIdx,
            maxTime: maxTime,
            flagImageName: nil,
            memorySteps: nil,
            memoryGridItems: items,
            memoryPreviewSeconds: previewSecs
        )
    }

    // MARK: - 13. Chemistry Symbols
    private func generateChemSymbols(level: GameLevel, maxTime: Double) -> Question {
        let idx = selectElementIndex(level: level)
        let targetElem = allElements[idx]

        var choicesSet = Set<String>([targetElem.name])
        while choicesSet.count < 4 {
            if let rand = allElements.randomElement() {
                choicesSet.insert(rand.name)
            }
        }

        let rawOptions = Array(choicesSet).shuffled()
        let localizedTarget = localizedElementName(for: targetElem.name)
        let localizedOptions = rawOptions.map { localizedElementName(for: $0) }
        let correctIdx = localizedOptions.firstIndex(of: localizedTarget) ?? 0

        return Question(
            text: targetElem.symbol,
            subtext: NSLocalizedString("prompt_chem_symbol", comment: "Which element symbol"),
            options: localizedOptions,
            correctIndex: correctIdx,
            maxTime: maxTime,
            flagImageName: nil,
            memorySteps: nil,
            memoryGridItems: nil,
            memoryPreviewSeconds: nil
        )
    }

    // MARK: - 14. Chemistry Names
    private func generateChemNames(level: GameLevel, maxTime: Double) -> Question {
        let idx = selectElementIndex(level: level)
        let targetElem = allElements[idx]

        var choicesSet = Set<String>([targetElem.symbol])
        while choicesSet.count < 4 {
            if let rand = allElements.randomElement() {
                choicesSet.insert(rand.symbol)
            }
        }

        let options = Array(choicesSet).shuffled()
        let correctIdx = options.firstIndex(of: targetElem.symbol) ?? 0
        let localizedTargetName = localizedElementName(for: targetElem.name)

        return Question(
            text: localizedTargetName,
            subtext: NSLocalizedString("prompt_chem_name", comment: "What is symbol"),
            options: options,
            correctIndex: correctIdx,
            maxTime: maxTime,
            flagImageName: nil,
            memorySteps: nil,
            memoryGridItems: nil,
            memoryPreviewSeconds: nil
        )
    }

    // MARK: - 15. Flags
    private func generateFlags(level: GameLevel, maxTime: Double) -> Question {
        let totalCount = allCountries.count
        guard totalCount > 0 else {
            let target = localizedCountryName(for: "Poland")
            return Question(
                text: target,
                subtext: NSLocalizedString("prompt_flag", comment: "Flag question"),
                options: [localizedCountryName(for: "Poland"), localizedCountryName(for: "Germany"), localizedCountryName(for: "France"), localizedCountryName(for: "Italy")],
                correctIndex: 0,
                maxTime: maxTime,
                flagImageName: "Poland",
                memorySteps: nil,
                memoryGridItems: nil,
                memoryPreviewSeconds: nil
            )
        }

        let countryIndex: Int
        switch level {
        case .beginner:
            countryIndex = Int.random(in: 0..<min(25, totalCount))
        case .easy:
            countryIndex = Int.random(in: 0..<min(50, totalCount))
        case .medium:
            countryIndex = Int.random(in: min(20, totalCount - 1)..<min(70, totalCount))
        case .hard:
            countryIndex = Int.random(in: min(40, totalCount - 1)..<min(120, totalCount))
        case .ultimate:
            countryIndex = Int.random(in: min(60, totalCount - 1)..<min(110, totalCount))
        case .godlike:
            countryIndex = Int.random(in: min(60, totalCount - 1)..<totalCount)
        }

        let rawTargetCountry = allCountries[countryIndex]
        let flagAssetName = rawTargetCountry.replacingOccurrences(of: " ", with: "_")

        var choicesSet = Set<String>([rawTargetCountry])
        while choicesSet.count < 4 {
            if let randomCountry = allCountries.randomElement() {
                choicesSet.insert(randomCountry)
            }
        }

        let rawOptions = Array(choicesSet).shuffled()
        let localizedTarget = localizedCountryName(for: rawTargetCountry)
        let localizedOptions = rawOptions.map { localizedCountryName(for: $0) }
        let correctIdx = localizedOptions.firstIndex(of: localizedTarget) ?? 0

        return Question(
            text: localizedTarget,
            subtext: NSLocalizedString("prompt_flag", comment: "Flag question"),
            options: localizedOptions,
            correctIndex: correctIdx,
            maxTime: maxTime,
            flagImageName: flagAssetName,
            memorySteps: nil,
            memoryGridItems: nil,
            memoryPreviewSeconds: nil
        )
    }

    // Helper: generate 4 unique numeric choices
    private func makeNumericOptions(correct: Int, range: Int, minVal: Int = 0, maxVal: Int? = nil) -> [String] {
        var set = Set<Int>([correct])
        
        if let upper = maxVal {
            var candidates = Array(minVal...upper).filter { $0 != correct }
            candidates.sort { c1, c2 in
                let d1 = abs(c1 - correct)
                let d2 = abs(c2 - correct)
                if d1 == d2 {
                    return Bool.random()
                }
                return d1 < d2
            }
            for val in candidates {
                if set.count >= 4 { break }
                set.insert(val)
            }
            var extra = 1
            while set.count < 4 {
                let val = upper + extra
                set.insert(val)
                extra += 1
            }
        } else {
            var delta = 1
            while set.count < 4 {
                let offset = (Bool.random() ? 1 : -1) * (delta + Int.random(in: 0...2))
                let val = max(minVal, correct + offset)
                if val != correct {
                    set.insert(val)
                }
                delta += 2
            }
        }
        return set.map { "\($0)" }.shuffled()
    }

    // MARK: - Pre-generate 15 Unique Questions for Game Session
    // MARK: - Item Keys for a Level (used for per-level progress display)
    func itemKeysForLevel(gameType: GameType, level: GameLevel) -> [String] {
        if gameType == .flags {
            let totalCount = allCountries.count
            guard totalCount > 0 else { return [] }
            let range: Range<Int>
            switch level {
            case .beginner: range = 0..<min(25, totalCount)
            case .easy: range = 0..<min(50, totalCount)
            case .medium: range = min(20, totalCount - 1)..<min(70, totalCount)
            case .hard: range = min(40, totalCount - 1)..<min(120, totalCount)
            case .ultimate: range = min(60, totalCount - 1)..<min(110, totalCount)
            case .godlike: range = min(60, totalCount - 1)..<totalCount
            }
            return range.map { "country_\(allCountries[$0])" }
        } else if gameType == .chemSymbols || gameType == .chemNames {
            let total = allElements.count
            guard total > 0 else { return [] }
            let range: Range<Int>
            switch level {
            case .beginner: range = 0..<min(25, total)
            case .easy: range = 0..<min(50, total)
            case .medium: range = min(20, total - 1)..<min(70, total)
            case .hard: range = min(40, total - 1)..<min(90, total)
            case .ultimate: range = min(60, total - 1)..<min(110, total)
            case .godlike: range = min(65, total - 1)..<total
            }
            return range.map { "chem_\(allElements[$0].symbol)" }
        } else if gameType == .addition {
            if level == .beginner {
                var keys: [String] = []
                for a in 1...5 {
                    for b in 1...5 {
                        keys.append("math_add_\(a)_\(b)")
                    }
                }
                return keys
            } else if level == .easy {
                var keys: [String] = []
                for a in 1...10 {
                    for b in 1...10 {
                        keys.append("math_add_\(a)_\(b)")
                    }
                }
                return keys
            }
        } else if gameType == .subtraction {
            if level == .beginner {
                var keys: [String] = []
                for diff in 1...5 {
                    for b in 1...5 {
                        let a = b + diff
                        keys.append("math_sub_\(a)_\(b)")
                    }
                }
                return keys
            } else if level == .easy {
                var keys: [String] = []
                for diff in 1...10 {
                    for b in 1...10 {
                        let a = b + diff
                        keys.append("math_sub_\(a)_\(b)")
                    }
                }
                return keys
            }
        } else if gameType == .multiplication {
            if level == .beginner {
                var keys: [String] = []
                for a in 1...5 {
                    for b in 1...5 {
                        keys.append("math_mult_\(a)_\(b)")
                    }
                }
                return keys
            } else if level == .easy {
                var keys: [String] = []
                for a in 1...10 {
                    for b in 1...10 {
                        keys.append("math_mult_\(a)_\(b)")
                    }
                }
                return keys
            }
        } else if gameType == .division {
            if level == .beginner {
                var keys: [String] = []
                for q in 1...5 {
                    for b in 1...5 {
                        let a = b * q
                        keys.append("math_div_\(a)_\(b)")
                    }
                }
                return keys
            } else if level == .easy {
                var keys: [String] = []
                for q in 1...10 {
                    for b in 1...10 {
                        let a = b * q
                        keys.append("math_div_\(a)_\(b)")
                    }
                }
                return keys
            }
        }
        return []
    }

    func generateGameQuestions(gameType: GameType, level: GameLevel, playerID: String, count: Int = 15) -> [Question] {
        let maxTime = getMaxTime(for: level)

        switch gameType {
        case .flags:
            return generateFlagsQuestions(level: level, playerID: playerID, count: count, maxTime: maxTime)
        case .chemSymbols:
            return generateChemSymbolsQuestions(level: level, playerID: playerID, count: count, maxTime: maxTime)
        case .chemNames:
            return generateChemNamesQuestions(level: level, playerID: playerID, count: count, maxTime: maxTime)
        case .addition, .subtraction, .multiplication, .division:
            if level == .beginner || level == .easy {
                return generateMathProgressQuestions(gameType: gameType, level: level, playerID: playerID, count: count, maxTime: maxTime)
            } else {
                return generateGenericQuestions(gameType: gameType, level: level, playerID: playerID, count: count, maxTime: maxTime)
            }
        default:
            return generateGenericQuestions(gameType: gameType, level: level, playerID: playerID, count: count, maxTime: maxTime)
        }
    }

    private func generateFlagsQuestions(level: GameLevel, playerID: String, count: Int, maxTime: Double) -> [Question] {
        let totalCount = allCountries.count
        guard totalCount > 0 else { return [] }

        let availableIndices: [Int]
        switch level {
        case .beginner: availableIndices = Array(0..<min(25, totalCount))
        case .easy: availableIndices = Array(0..<min(50, totalCount))
        case .medium: availableIndices = Array(min(20, totalCount - 1)..<min(70, totalCount))
        case .hard: availableIndices = Array(min(40, totalCount - 1)..<min(120, totalCount))
        case .ultimate: availableIndices = Array(min(60, totalCount - 1)..<min(110, totalCount))
        case .godlike: availableIndices = Array(min(60, totalCount - 1)..<totalCount)
        }

        var priority1: [Int] = []
        var priority2: [Int] = []

        for idx in availableIndices {
            let country = allCountries[idx]
            let key = "country_\(country)"
            let status = ItemProgressTracker.shared.getStatus(for: key, playerID: playerID)
            if status == .correct {
                priority2.append(idx)
            } else {
                priority1.append(idx)
            }
        }

        priority1.shuffle()
        priority2.shuffle()

        var selectedIndices: [Int] = []
        selectedIndices.append(contentsOf: priority1.prefix(count))
        if selectedIndices.count < count {
            let needed = count - selectedIndices.count
            selectedIndices.append(contentsOf: priority2.prefix(needed))
        }

        if selectedIndices.count < count {
            let remaining = availableIndices.filter { !selectedIndices.contains($0) }.shuffled()
            selectedIndices.append(contentsOf: remaining.prefix(count - selectedIndices.count))
        }

        selectedIndices.shuffle()

        return selectedIndices.map { idx in
            let rawTargetCountry = allCountries[idx]
            let itemKey = "country_\(rawTargetCountry)"
            let flagAssetName = rawTargetCountry.replacingOccurrences(of: " ", with: "_")
            var choicesSet = Set<String>([rawTargetCountry])
            while choicesSet.count < 4 {
                if let rand = allCountries.randomElement() {
                    choicesSet.insert(rand)
                }
            }
            let rawOptions = Array(choicesSet).shuffled()
            let localizedTarget = localizedCountryName(for: rawTargetCountry)
            let localizedOptions = rawOptions.map { localizedCountryName(for: $0) }
            let correctIdx = localizedOptions.firstIndex(of: localizedTarget) ?? 0

            return Question(
                itemKey: itemKey,
                text: localizedTarget,
                subtext: NSLocalizedString("prompt_flag", comment: "Flag question"),
                options: localizedOptions,
                correctIndex: correctIdx,
                maxTime: maxTime,
                flagImageName: flagAssetName
            )
        }
    }

    private func generateChemSymbolsQuestions(level: GameLevel, playerID: String, count: Int, maxTime: Double) -> [Question] {
        let total = allElements.count
        guard total > 0 else { return [] }

        let indices: [Int]
        switch level {
        case .beginner: indices = Array(0..<min(25, total))
        case .easy: indices = Array(0..<min(50, total))
        case .medium: indices = Array(min(20, total - 1)..<min(70, total))
        case .hard: indices = Array(min(40, total - 1)..<min(90, total))
        case .ultimate: indices = Array(min(60, total - 1)..<min(110, total))
        case .godlike: indices = Array(min(65, total - 1)..<total)
        }

        var priority1: [Int] = []
        var priority2: [Int] = []

        for idx in indices {
            let elem = allElements[idx]
            let key = "chem_\(elem.symbol)"
            let status = ItemProgressTracker.shared.getStatus(for: key, playerID: playerID)
            if status == .correct {
                priority2.append(idx)
            } else {
                priority1.append(idx)
            }
        }

        priority1.shuffle()
        priority2.shuffle()

        var selectedIndices: [Int] = []
        selectedIndices.append(contentsOf: priority1.prefix(count))
        if selectedIndices.count < count {
            let needed = count - selectedIndices.count
            selectedIndices.append(contentsOf: priority2.prefix(needed))
        }

        if selectedIndices.count < count {
            let remaining = indices.filter { !selectedIndices.contains($0) }.shuffled()
            selectedIndices.append(contentsOf: remaining.prefix(count - selectedIndices.count))
        }

        while selectedIndices.count < count {
            if let randIdx = indices.randomElement() {
                selectedIndices.append(randIdx)
            }
        }

        selectedIndices.shuffle()

        return selectedIndices.map { idx in
            let targetElem = allElements[idx]
            let itemKey = "chem_\(targetElem.symbol)"
            var choicesSet = Set<String>([targetElem.name])
            while choicesSet.count < 4 {
                if let rand = allElements.randomElement() {
                    choicesSet.insert(rand.name)
                }
            }
            let rawOptions = Array(choicesSet).shuffled()
            let localizedTarget = localizedElementName(for: targetElem.name)
            let localizedOptions = rawOptions.map { localizedElementName(for: $0) }
            let correctIdx = localizedOptions.firstIndex(of: localizedTarget) ?? 0

            return Question(
                itemKey: itemKey,
                text: targetElem.symbol,
                subtext: NSLocalizedString("prompt_chem_symbol", comment: "What element"),
                options: localizedOptions,
                correctIndex: correctIdx,
                maxTime: maxTime
            )
        }
    }

    private func generateChemNamesQuestions(level: GameLevel, playerID: String, count: Int, maxTime: Double) -> [Question] {
        let total = allElements.count
        guard total > 0 else { return [] }

        let indices: [Int]
        switch level {
        case .beginner: indices = Array(0..<min(25, total))
        case .easy: indices = Array(0..<min(50, total))
        case .medium: indices = Array(min(20, total - 1)..<min(70, total))
        case .hard: indices = Array(min(40, total - 1)..<min(90, total))
        case .ultimate: indices = Array(min(60, total - 1)..<min(110, total))
        case .godlike: indices = Array(min(65, total - 1)..<total)
        }

        var priority1: [Int] = []
        var priority2: [Int] = []

        for idx in indices {
            let elem = allElements[idx]
            let key = "chem_\(elem.symbol)"
            let status = ItemProgressTracker.shared.getStatus(for: key, playerID: playerID)
            if status == .correct {
                priority2.append(idx)
            } else {
                priority1.append(idx)
            }
        }

        priority1.shuffle()
        priority2.shuffle()

        var selectedIndices: [Int] = []
        selectedIndices.append(contentsOf: priority1.prefix(count))
        if selectedIndices.count < count {
            let needed = count - selectedIndices.count
            selectedIndices.append(contentsOf: priority2.prefix(needed))
        }

        if selectedIndices.count < count {
            let remaining = indices.filter { !selectedIndices.contains($0) }.shuffled()
            selectedIndices.append(contentsOf: remaining.prefix(count - selectedIndices.count))
        }

        while selectedIndices.count < count {
            if let randIdx = indices.randomElement() {
                selectedIndices.append(randIdx)
            }
        }

        selectedIndices.shuffle()

        return selectedIndices.map { idx in
            let targetElem = allElements[idx]
            let itemKey = "chem_\(targetElem.symbol)"
            var choicesSet = Set<String>([targetElem.symbol])
            while choicesSet.count < 4 {
                if let rand = allElements.randomElement() {
                    choicesSet.insert(rand.symbol)
                }
            }
            let options = Array(choicesSet).shuffled()
            let correctIdx = options.firstIndex(of: targetElem.symbol) ?? 0
            let localizedTargetName = localizedElementName(for: targetElem.name)

            return Question(
                itemKey: itemKey,
                text: localizedTargetName,
                subtext: NSLocalizedString("prompt_chem_name", comment: "What is symbol"),
                options: options,
                correctIndex: correctIdx,
                maxTime: maxTime
            )
        }
    }

    private func generateGenericQuestions(gameType: GameType, level: GameLevel, playerID: String, count: Int, maxTime: Double) -> [Question] {
        var questions: [Question] = []
        var usedSignatures = Set<String>()

        var attempts = 0
        while questions.count < count && attempts < 500 {
            attempts += 1
            let q = generateQuestion(gameType: gameType, level: level)

            let signature: String
            if let steps = q.memorySteps {
                signature = steps.joined(separator: "_")
            } else if let grid = q.memoryGridItems {
                let gridSig = grid.map { "\($0.shapeSymbol)_\($0.colorName)" }.joined(separator: ",")
                signature = "\(q.text)_\(gridSig)"
            } else {
                signature = q.text
            }

            if !usedSignatures.contains(signature) {
                usedSignatures.insert(signature)
                let itemKey = "math_\(gameType.rawValue)_\(signature)"
                let questionWithKey = Question(
                    itemKey: itemKey,
                    text: q.text,
                    subtext: q.subtext,
                    options: q.options,
                    correctIndex: q.correctIndex,
                    maxTime: q.maxTime,
                    flagImageName: q.flagImageName,
                    memorySteps: q.memorySteps,
                    memoryGridItems: q.memoryGridItems,
                    memoryPreviewSeconds: q.memoryPreviewSeconds
                )
                questions.append(questionWithKey)
            }
        }

        // Fallback: If unique signatures produced fewer than count questions, fill up to count (15)
        while questions.count < count {
            let q = generateQuestion(gameType: gameType, level: level)
            let itemKey = "math_\(gameType.rawValue)_\(questions.count)_\(q.text)"
            let questionWithKey = Question(
                itemKey: itemKey,
                text: q.text,
                subtext: q.subtext,
                options: q.options,
                correctIndex: q.correctIndex,
                maxTime: q.maxTime,
                flagImageName: q.flagImageName,
                memorySteps: q.memorySteps,
                memoryGridItems: q.memoryGridItems,
                memoryPreviewSeconds: q.memoryPreviewSeconds
            )
            questions.append(questionWithKey)
        }

        return questions
    }


    private func generateMathProgressQuestions(gameType: GameType, level: GameLevel, playerID: String, count: Int, maxTime: Double) -> [Question] {
        let keys = itemKeysForLevel(gameType: gameType, level: level)
        guard !keys.isEmpty else {
            return generateGenericQuestions(gameType: gameType, level: level, playerID: playerID, count: count, maxTime: maxTime)
        }

        var priority1: [String] = []
        var priority2: [String] = []

        for key in keys {
            let status = ItemProgressTracker.shared.getStatus(for: key, playerID: playerID)
            if status == .correct {
                priority2.append(key)
            } else {
                priority1.append(key)
            }
        }

        priority1.shuffle()
        priority2.shuffle()

        var selectedKeys: [String] = []
        selectedKeys.append(contentsOf: priority1.prefix(count))
        if selectedKeys.count < count {
            let needed = count - selectedKeys.count
            selectedKeys.append(contentsOf: priority2.prefix(needed))
        }

        if selectedKeys.count < count {
            let remaining = keys.filter { !selectedKeys.contains($0) }.shuffled()
            selectedKeys.append(contentsOf: remaining.prefix(count - selectedKeys.count))
        }

        while selectedKeys.count < count {
            if let randKey = keys.randomElement() {
                selectedKeys.append(randKey)
            }
        }

        selectedKeys.shuffle()

        return selectedKeys.map { key in
            makeMathQuestionFromKey(key: key, gameType: gameType, maxTime: maxTime)
        }
    }

    private func makeMathQuestionFromKey(key: String, gameType: GameType, maxTime: Double) -> Question {
        let parts = key.split(separator: "_")
        guard parts.count >= 4, let a = Int(parts[2]), let b = Int(parts[3]) else {
            return generateQuestion(gameType: gameType, level: .easy)
        }

        let text: String
        let subtext: String
        let correct: Int

        switch gameType {
        case .addition:
            text = "\(a) + \(b)"
            subtext = NSLocalizedString("prompt_calc_sum", comment: "Calculate sum")
            correct = a + b
        case .subtraction:
            text = "\(a) - \(b)"
            subtext = NSLocalizedString("prompt_calc_diff", comment: "Calculate difference")
            correct = a - b
        case .multiplication:
            text = "\(a) × \(b)"
            subtext = NSLocalizedString("prompt_calc_product", comment: "Calculate product")
            correct = a * b
        case .division:
            text = "\(a) ÷ \(b)"
            subtext = NSLocalizedString("prompt_calc_quotient", comment: "Calculate quotient")
            correct = a / b
        default:
            text = "\(a) + \(b)"
            subtext = ""
            correct = a + b
        }

        let options = makeNumericOptions(correct: correct, range: 10)
        let correctIdx = options.firstIndex(of: "\(correct)") ?? 0

        return Question(
            itemKey: key,
            text: text,
            subtext: subtext,
            options: options,
            correctIndex: correctIdx,
            maxTime: maxTime,
            flagImageName: nil,
            memorySteps: nil,
            memoryGridItems: nil,
            memoryPreviewSeconds: nil
        )
    }
}

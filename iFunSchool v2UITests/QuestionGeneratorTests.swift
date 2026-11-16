//
//  QuestionGeneratorTests.swift
//  iFunSchool v2UITests
//
//  Unit tests for QuestionGenerator:
//  - Verifies mental math step generation
//  - Ensures consecutive operations never repeat after each other
//  - Ensures intermediate values never drop below 0
//  - Ensures correct mathematical calculation matching displayed steps
//

import XCTest
import SwiftUI
import Foundation

final class QuestionGeneratorTests: XCTestCase {

    // MARK: - 1. Mental Addition Tests
    func testMemoryAddNoConsecutiveDuplicates() throws {
        for level in GameLevel.allCases {
            for iteration in 0..<50 {
                let q = QuestionGenerator.shared.generateQuestion(gameType: .memoryAdd, level: level)
                guard let steps = q.memorySteps, steps.count >= 2 else {
                    XCTFail("memoryAdd question missing steps for level \(level) at iteration \(iteration)")
                    return
                }

                // Verify consecutive operations do not repeat
                for i in 2..<steps.count {
                    XCTAssertNotEqual(steps[i], steps[i-1], "Consecutive step repeated at index \(i): \(steps[i]) == \(steps[i-1]) for level \(level)")
                }

                // Verify starting number + sum of steps matches correct answer
                let firstVal = Int(steps[0]) ?? 0
                var sum = firstVal
                for i in 1..<steps.count {
                    let step = steps[i]
                    XCTAssertTrue(step.hasPrefix("+"), "Memory add step must start with +: \(step)")
                    let valStr = String(step.dropFirst())
                    let val = Int(valStr) ?? 0
                    sum += val
                }

                let expectedOptions = q.options[q.correctIndex]
                XCTAssertEqual("\(sum)", expectedOptions, "Correct answer \(expectedOptions) does not match computed sum \(sum) for steps \(steps)")
            }
        }
    }

    // MARK: - 2. Mental Addition & Subtraction Tests
    func testMemoryAddSubNoDuplicatesAndNoBelowZero() throws {
        for level in GameLevel.allCases {
            for iteration in 0..<50 {
                let q = QuestionGenerator.shared.generateQuestion(gameType: .memoryAddSub, level: level)
                guard let steps = q.memorySteps, steps.count >= 2 else {
                    XCTFail("memoryAddSub question missing steps for level \(level) at iteration \(iteration)")
                    return
                }

                // Verify consecutive operations do not repeat
                for i in 2..<steps.count {
                    XCTAssertNotEqual(steps[i], steps[i-1], "Consecutive step repeated at index \(i): \(steps[i]) == \(steps[i-1]) for level \(level)")
                }

                // Verify intermediate calculations never drop below 0
                let firstVal = Int(steps[0]) ?? 0
                var current = firstVal
                XCTAssertGreaterThanOrEqual(current, 0, "Initial value is below 0: \(current)")

                for i in 1..<steps.count {
                    let step = steps[i]
                    if step.hasPrefix("+") {
                        let val = Int(String(step.dropFirst())) ?? 0
                        current += val
                    } else if step.hasPrefix("-") {
                        let val = Int(String(step.dropFirst())) ?? 0
                        current -= val
                    } else {
                        XCTFail("Unexpected step format in memoryAddSub: \(step)")
                    }

                    XCTAssertGreaterThanOrEqual(current, 0, "Intermediate result dropped below 0 at step \(i) (\(step)): current = \(current), steps = \(steps)")
                }

                let expectedOptions = q.options[q.correctIndex]
                XCTAssertEqual("\(current)", expectedOptions, "Correct answer \(expectedOptions) does not match computed math \(current) for steps \(steps)")
            }
        }
    }

    // MARK: - 3. Mental Math Operations (Add, Sub, Mult) Tests
    func testMemoryAddSubMultNoDuplicatesAndNoBelowZero() throws {
        for level in GameLevel.allCases {
            for iteration in 0..<50 {
                let q = QuestionGenerator.shared.generateQuestion(gameType: .memoryAddSubMult, level: level)
                guard let steps = q.memorySteps, steps.count >= 2 else {
                    XCTFail("memoryAddSubMult question missing steps for level \(level) at iteration \(iteration)")
                    return
                }

                // Verify consecutive operations do not repeat
                for i in 2..<steps.count {
                    XCTAssertNotEqual(steps[i], steps[i-1], "Consecutive step repeated at index \(i): \(steps[i]) == \(steps[i-1]) for level \(level)")
                }

                // Verify intermediate calculations never drop below 0
                let firstVal = Int(steps[0]) ?? 0
                var current = firstVal
                XCTAssertGreaterThanOrEqual(current, 0, "Initial value is below 0: \(current)")

                for i in 1..<steps.count {
                    let step = steps[i]
                    if step.hasPrefix("+") {
                        let val = Int(String(step.dropFirst())) ?? 0
                        current += val
                    } else if step.hasPrefix("-") {
                        let val = Int(String(step.dropFirst())) ?? 0
                        current -= val
                    } else if step.hasPrefix("×") {
                        let val = Int(String(step.dropFirst())) ?? 0
                        current *= val
                    } else {
                        XCTFail("Unexpected step format in memoryAddSubMult: \(step)")
                    }

                    XCTAssertGreaterThanOrEqual(current, 0, "Intermediate result dropped below 0 at step \(i) (\(step)): current = \(current), steps = \(steps)")
                }

                let expectedOptions = q.options[q.correctIndex]
                XCTAssertEqual("\(current)", expectedOptions, "Correct answer \(expectedOptions) does not match computed math \(current) for steps \(steps)")
            }
        }
    }

    // MARK: - 4. All 15 Games × 6 Levels Smoke & Correctness Test
    func testAll15GamesGenerateValidQuestionsForAll6Levels() throws {
        for gameType in GameType.allCases {
            for level in GameLevel.allCases {
                for qIndex in [0, 7, 14] {
                    let q = QuestionGenerator.shared.generateQuestion(gameType: gameType, level: level, questionIndex: qIndex)
                    XCTAssertFalse(q.text.isEmpty, "Question text empty for \(gameType) level \(level)")
                    XCTAssertEqual(q.options.count, 4, "Options count should be 4 for \(gameType) level \(level)")
                    XCTAssertTrue(q.correctIndex >= 0 && q.correctIndex < 4, "Invalid correctIndex for \(gameType) level \(level)")
                    XCTAssertGreaterThan(q.maxTime, 0, "Invalid maxTime for \(gameType) level \(level)")

                    let uniqueOptions = Set(q.options)
                    XCTAssertEqual(uniqueOptions.count, 4, "Duplicate options generated in \(gameType) level \(level): \(q.options)")
                }
            }
        }
    }

    // MARK: - 5. Godlike Memory Escalation (8 steps at q1 -> 23 steps at q15)
    func testGodlikeMemoryProgressionFrom8To23Steps() throws {
        let memoryGames: [GameType] = [.memoryAdd, .memoryAddSub, .memoryAddSubMult]
        for game in memoryGames {
            let qFirst = QuestionGenerator.shared.generateQuestion(gameType: game, level: .godlike, questionIndex: 0)
            XCTAssertEqual(qFirst.memorySteps?.count, 8, "\(game) at Godlike question 0 must have exactly 8 steps")

            let qMid = QuestionGenerator.shared.generateQuestion(gameType: game, level: .godlike, questionIndex: 7)
            XCTAssertEqual(qMid.memorySteps?.count, 16, "\(game) at Godlike question 7 must have 16 steps")

            let qLast = QuestionGenerator.shared.generateQuestion(gameType: game, level: .godlike, questionIndex: 14)
            XCTAssertEqual(qLast.memorySteps?.count, 23, "\(game) at Godlike question 14 must have exactly 23 steps")
        }
    }

    // MARK: - 6. Full Game Session Question Generation Test
    func testFullGameQuestionsGenerationFor15Questions() throws {
        for game in GameType.allCases {
            for level in [GameLevel.beginner, GameLevel.hard, GameLevel.godlike] {
                let questions = QuestionGenerator.shared.generateGameQuestions(
                    gameType: game,
                    level: level,
                    playerID: "test_player",
                    count: 15
                )
                XCTAssertEqual(questions.count, 15, "Expected 15 questions for \(game) at \(level)")
            }
        }
    }

    // MARK: - 7. Distractor Diversity & Anti-Meta-Gaming Test
    func testDistractorDiversityAndMultiStrategyPools() throws {
        var sawSameLastDigitInMult = false
        var sawSameLastDigitInAdd = false

        for qIdx in 0..<30 {
            let qMult = QuestionGenerator.shared.generateQuestion(gameType: .multiplication, level: .godlike, questionIndex: qIdx % 15)
            let correctMultStr = qMult.options[qMult.correctIndex]
            if let correctLast = correctMultStr.last {
                for (idx, opt) in qMult.options.enumerated() where idx != qMult.correctIndex {
                    if opt.last == correctLast {
                        sawSameLastDigitInMult = true
                        break
                    }
                }
            }

            let qAdd = QuestionGenerator.shared.generateQuestion(gameType: .addition, level: .godlike, questionIndex: qIdx % 15)
            let correctAddStr = qAdd.options[qAdd.correctIndex]
            if let correctLast = correctAddStr.last {
                for (idx, opt) in qAdd.options.enumerated() where idx != qAdd.correctIndex {
                    if opt.last == correctLast {
                        sawSameLastDigitInAdd = true
                        break
                    }
                }
            }
        }

        XCTAssertTrue(sawSameLastDigitInMult, "Multi-strategy generator should produce same-last-digit distractors in multiplication to prevent last-digit exploit")
        XCTAssertTrue(sawSameLastDigitInAdd, "Multi-strategy generator should produce same-last-digit distractors in addition to prevent last-digit exploit")
    }

    // MARK: - 8. Capitals (Państwa - miasta) Tests
    func testCapitalsAllCountriesCoveredAndPoolsCorrect() throws {
        let gen = QuestionGenerator.shared
        XCTAssertEqual(gen.allCountries.count, 203, "Expected 203 total countries")

        var seenCapitals = Set<String>()
        for country in gen.allCountries {
            let capital = gen.capitalCity(for: country)
            XCTAssertFalse(capital.isEmpty, "Missing capital for country \(country)")
            XCTAssertFalse(seenCapitals.contains(capital), "Duplicate capital \(capital) for country \(country)")
            seenCapitals.insert(capital)

            let cities = gen.cities(for: country)
            XCTAssertGreaterThanOrEqual(cities.count, 1, "Country \(country) must have at least 1 city")
            XCTAssertEqual(cities[0], capital, "First city for \(country) must be its capital")
            for city in cities {
                let localized = gen.localizedCityName(for: city)
                XCTAssertFalse(localized.isEmpty, "Localized name for city \(city) should not be empty")
                XCTAssertFalse(localized.hasPrefix("city_"), "City \(city) is missing translation in Localizable.xcstrings (got \(localized))")
            }
        }

        // Verify level pools
        XCTAssertEqual(gen.capitalsPool(for: .beginner).count, 46, "Beginner (Europe) should have 46 countries")
        XCTAssertTrue(gen.capitalsPool(for: .beginner).contains("Poland"))
        XCTAssertEqual(gen.capitalsPool(for: .easy).count, 35, "Easy (Americas) should have 35 countries")
        XCTAssertTrue(gen.capitalsPool(for: .easy).contains("United States"))
        XCTAssertEqual(gen.capitalsPool(for: .medium).count, 48, "Medium (Asia) should have 48 countries")
        XCTAssertTrue(gen.capitalsPool(for: .medium).contains("Japan"))
        XCTAssertEqual(gen.capitalsPool(for: .hard).count, 54, "Hard (Africa) should have 54 countries")
        XCTAssertTrue(gen.capitalsPool(for: .hard).contains("Egypt"))
        XCTAssertEqual(gen.capitalsPool(for: .ultimate).count, 64, "Ultimate (World Hard) should have 64 countries")
        XCTAssertTrue(gen.capitalsPool(for: .ultimate).contains("Australia"))
        XCTAssertEqual(gen.capitalsPool(for: .godlike), gen.allCountries)

        // Verify both directions and same-country distractors for Poland
        let qAskCapital = gen.makeCapitalQuestion(
            targetCountry: "Poland",
            level: .beginner,
            maxTime: 10.0,
            askForCapital: true
        )
        XCTAssertEqual(qAskCapital.itemKey, "city_Warsaw")
        XCTAssertEqual(qAskCapital.options.count, 4)
        XCTAssertEqual(Set(qAskCapital.options).count, 4)
        XCTAssertEqual(qAskCapital.options[qAskCapital.correctIndex], gen.localizedCityName(for: "Warsaw"))
        // Since Poland has 4 cities (Warsaw, Krakow, Lodz, Wroclaw), all 3 distractors should be Polish cities
        let expectedPolishCities = Set(["Warsaw", "Krakow", "Lodz", "Wroclaw"].map { gen.localizedCityName(for: $0) })
        XCTAssertEqual(Set(qAskCapital.options), expectedPolishCities, "When a country has 4 cities, asking for its capital should use its 3 other largest cities as distractors")

        let qAskCountry = gen.makeCapitalQuestion(
            targetCountry: "Poland",
            level: .beginner,
            maxTime: 10.0,
            askForCapital: false
        )
        XCTAssertEqual(qAskCountry.itemKey, "city_Warsaw")
        XCTAssertEqual(qAskCountry.options.count, 4)
        XCTAssertEqual(Set(qAskCountry.options).count, 4)
        XCTAssertEqual(qAskCountry.options[qAskCountry.correctIndex], gen.localizedCountryName(for: "Poland"))
    }

    // MARK: - 9. Roman Numerals Tests
    func testRomanNumeralsAllLevelsAndProgress() throws {
        let gen = QuestionGenerator.shared
        XCTAssertEqual(gen.toRoman(4), "IV")
        XCTAssertEqual(gen.toRoman(49), "XLIX")
        XCTAssertEqual(gen.toRoman(1999), "MCMXCIX")
        XCTAssertEqual(gen.toRoman(3999), "MMMCMXCIX")

        XCTAssertEqual(gen.itemKeysForLevel(gameType: .romanNumerals, level: .beginner).count, 20)
        XCTAssertEqual(gen.itemKeysForLevel(gameType: .romanNumerals, level: .easy).count, 50)
        XCTAssertEqual(gen.itemKeysForLevel(gameType: .romanNumerals, level: .medium).count, 100)
        XCTAssertEqual(gen.itemKeysForLevel(gameType: .romanNumerals, level: .hard).count, 40)
        XCTAssertEqual(gen.itemKeysForLevel(gameType: .romanNumerals, level: .ultimate).count, 40)
        XCTAssertTrue(gen.itemKeysForLevel(gameType: .romanNumerals, level: .godlike).isEmpty)

        for level in GameLevel.allCases {
            for _ in 0..<25 {
                let q = gen.generateQuestion(gameType: .romanNumerals, level: level)
                XCTAssertFalse(q.text.isEmpty)
                XCTAssertEqual(q.options.count, 4)
                XCTAssertEqual(Set(q.options).count, 4)
                XCTAssertTrue(q.correctIndex >= 0 && q.correctIndex < 4)
            }
            let session = gen.generateGameQuestions(gameType: .romanNumerals, level: level, playerID: "test_roman", count: 15)
            XCTAssertEqual(session.count, 15)
            XCTAssertEqual(Set(session.map { $0.itemKey }).count, 15, "Session questions should be unique for Roman Numerals \(level)")
        }
    }

    // MARK: - 10. Powers & Roots Tests
    func testPowersRootsAllLevelsAndProgress() throws {
        let gen = QuestionGenerator.shared
        XCTAssertEqual(gen.itemKeysForLevel(gameType: .powersRoots, level: .beginner).count, 25)
        XCTAssertEqual(gen.itemKeysForLevel(gameType: .powersRoots, level: .easy).count, 40)
        XCTAssertEqual(gen.itemKeysForLevel(gameType: .powersRoots, level: .medium).count, 31)
        XCTAssertEqual(gen.itemKeysForLevel(gameType: .powersRoots, level: .hard).count, 39)
        XCTAssertEqual(gen.itemKeysForLevel(gameType: .powersRoots, level: .ultimate).count, 26)
        XCTAssertTrue(gen.itemKeysForLevel(gameType: .powersRoots, level: .godlike).isEmpty)

        for level in GameLevel.allCases {
            for _ in 0..<25 {
                let q = gen.generateQuestion(gameType: .powersRoots, level: level)
                XCTAssertFalse(q.text.isEmpty)
                XCTAssertEqual(q.options.count, 4)
                XCTAssertEqual(Set(q.options).count, 4)
                XCTAssertTrue(q.correctIndex >= 0 && q.correctIndex < 4)
            }
            let session = gen.generateGameQuestions(gameType: .powersRoots, level: level, playerID: "test_powers", count: 15)
            XCTAssertEqual(session.count, 15)
            XCTAssertEqual(Set(session.map { $0.itemKey }).count, 15, "Session questions should be unique for Powers & Roots \(level)")
        }
    }

    // MARK: - 11. Fractions, Decimals & Percentages Tests
    func testFractionsAllLevelsAndProgress() throws {
        let gen = QuestionGenerator.shared
        XCTAssertEqual(gen.itemKeysForLevel(gameType: .fractions, level: .beginner).count, 25)
        XCTAssertEqual(gen.itemKeysForLevel(gameType: .fractions, level: .easy).count, 30)
        XCTAssertEqual(gen.itemKeysForLevel(gameType: .fractions, level: .medium).count, 30)
        XCTAssertEqual(gen.itemKeysForLevel(gameType: .fractions, level: .hard).count, 30)
        XCTAssertEqual(gen.itemKeysForLevel(gameType: .fractions, level: .ultimate).count, 30)
        XCTAssertTrue(gen.itemKeysForLevel(gameType: .fractions, level: .godlike).isEmpty)

        for level in GameLevel.allCases {
            for _ in 0..<25 {
                let q = gen.generateQuestion(gameType: .fractions, level: level)
                XCTAssertFalse(q.text.isEmpty)
                XCTAssertEqual(q.options.count, 4)
                XCTAssertEqual(Set(q.options).count, 4)
                XCTAssertTrue(q.correctIndex >= 0 && q.correctIndex < 4)
            }
            let session = gen.generateGameQuestions(gameType: .fractions, level: level, playerID: "test_frac", count: 15)
            XCTAssertEqual(session.count, 15)
            XCTAssertEqual(Set(session.map { $0.itemKey }).count, 15, "Session questions should be unique for Fractions \(level)")
        }
    }

    // MARK: - 12. Unit Conversions & SI Prefixes Tests
    func testUnitConversionsAllLevelsAndProgress() throws {
        let gen = QuestionGenerator.shared
        XCTAssertEqual(gen.allUnitConversionItems.count, 150)
        for level in GameLevel.allCases {
            XCTAssertEqual(gen.itemKeysForLevel(gameType: .unitConversions, level: level).count, 25)
            for _ in 0..<25 {
                let q = gen.generateQuestion(gameType: .unitConversions, level: level)
                XCTAssertFalse(q.text.isEmpty)
                XCTAssertEqual(q.options.count, 4)
                XCTAssertEqual(Set(q.options).count, 4)
                XCTAssertTrue(q.correctIndex >= 0 && q.correctIndex < 4)
            }
            let session = gen.generateGameQuestions(gameType: .unitConversions, level: level, playerID: "test_units", count: 15)
            XCTAssertEqual(session.count, 15)
            XCTAssertEqual(Set(session.map { $0.itemKey }).count, 15, "Session questions should be unique for Unit Conversions \(level)")
        }
    }

    // MARK: - 13. Chemical Compounds & Formulas Tests
    func testChemCompoundsAllLevelsAndProgress() throws {
        let gen = QuestionGenerator.shared
        XCTAssertEqual(gen.allCompounds.count, 100)
        XCTAssertEqual(Set(gen.allCompounds.map { $0.formula }).count, 100)
        XCTAssertEqual(Set(gen.allCompounds.map { $0.key }).count, 100)

        XCTAssertEqual(gen.itemKeysForLevel(gameType: .chemCompounds, level: .beginner).count, 20)
        XCTAssertEqual(gen.itemKeysForLevel(gameType: .chemCompounds, level: .easy).count, 40)
        XCTAssertEqual(gen.itemKeysForLevel(gameType: .chemCompounds, level: .medium).count, 40)
        XCTAssertEqual(gen.itemKeysForLevel(gameType: .chemCompounds, level: .hard).count, 40)
        XCTAssertEqual(gen.itemKeysForLevel(gameType: .chemCompounds, level: .ultimate).count, 35)
        XCTAssertEqual(gen.itemKeysForLevel(gameType: .chemCompounds, level: .godlike).count, 30)

        for level in GameLevel.allCases {
            for _ in 0..<25 {
                let q = gen.generateQuestion(gameType: .chemCompounds, level: level)
                XCTAssertFalse(q.text.isEmpty)
                XCTAssertEqual(q.options.count, 4)
                XCTAssertEqual(Set(q.options).count, 4)
                XCTAssertTrue(q.correctIndex >= 0 && q.correctIndex < 4)
            }
            let session = gen.generateGameQuestions(gameType: .chemCompounds, level: level, playerID: "test_compounds", count: 15)
            XCTAssertEqual(session.count, 15)
            XCTAssertEqual(Set(session.map { $0.itemKey }).count, 15, "Session questions should be unique for Chemical Compounds \(level)")
        }
    }
}


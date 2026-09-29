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
}

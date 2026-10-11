//
//  iFunSchoolv2SnapshotUITests.swift
//  iFunSchool v2UITests
//
//  Automated Fastlane Snapshot UI Tests for App Store screenshots
//

import XCTest

@MainActor
class iFunSchoolv2SnapshotUITests: XCTestCase {

    @MainActor
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    @MainActor
    private func captureSnapshot(named name: String, launchArgument: String? = nil) {
        let app = XCUIApplication()
        setupSnapshot(app)
        if let arg = launchArgument {
            app.launchArguments.append(arg)
        }
        app.launch()

        // Wait for interactive buttons to exist, ensuring views are fully rendered and splash screen is bypassed
        _ = app.buttons.firstMatch.waitForExistence(timeout: 10)
        // Brief pause to allow SwiftUI transition animations to settle
        Thread.sleep(forTimeInterval: 1.0)

        snapshot(name)
        app.terminate()
        // Small pause after termination to let the tvOS simulator process clean up
        Thread.sleep(forTimeInterval: 0.5)
    }

    @MainActor
    func testTakeAppStoreScreenshots() throws {
        // -------------------------------------------------------------
        // 1. Main Menu / Game List Screen
        // -------------------------------------------------------------
        captureSnapshot(named: "01_MainScreen")

        // -------------------------------------------------------------
        // 2. Streak Calendar Screen
        // -------------------------------------------------------------
        captureSnapshot(named: "02_StreakScreen", launchArgument: "-UITestOpenStreak")

        // -------------------------------------------------------------
        // 3. Visual Progress View with Flags Category Selected
        // -------------------------------------------------------------
        captureSnapshot(named: "03_ProgressView_Flags", launchArgument: "-UITestOpenProgressFlags")

        // -------------------------------------------------------------
        // 4. Geography Flags Game View
        // -------------------------------------------------------------
        captureSnapshot(named: "04_FlagsGame", launchArgument: "-UITestOpenFlagsGame")

        // -------------------------------------------------------------
        // 5. Chemistry Elements Game View
        // -------------------------------------------------------------
        captureSnapshot(named: "05_ElementsGame", launchArgument: "-UITestOpenElementsGame")
    }
}

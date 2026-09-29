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
    func testTakeAppStoreScreenshots() throws {
        // -------------------------------------------------------------
        // 1. Main Menu / Game List Screen
        // -------------------------------------------------------------
        let app1 = XCUIApplication(bundleIdentifier: "pl.beling.ifunschool")
        setupSnapshot(app1)
        app1.launch()
        sleep(8)
        snapshot("01_MainScreen")
        app1.terminate()

        // -------------------------------------------------------------
        // 2. Streak Calendar Screen
        // -------------------------------------------------------------
        let app2 = XCUIApplication(bundleIdentifier: "pl.beling.ifunschool")
        setupSnapshot(app2)
        app2.launchArguments.append("-UITestOpenStreak")
        app2.launch()
        sleep(8)
        snapshot("02_StreakScreen")
        app2.terminate()

        // -------------------------------------------------------------
        // 3. Visual Progress View with Flags Category Selected
        // -------------------------------------------------------------
        let app3 = XCUIApplication(bundleIdentifier: "pl.beling.ifunschool")
        setupSnapshot(app3)
        app3.launchArguments.append("-UITestOpenProgressFlags")
        app3.launch()
        sleep(8)
        snapshot("03_ProgressView_Flags")
        app3.terminate()

        // -------------------------------------------------------------
        // 4. Geography Flags Game View
        // -------------------------------------------------------------
        let app4 = XCUIApplication(bundleIdentifier: "pl.beling.ifunschool")
        setupSnapshot(app4)
        app4.launchArguments.append("-UITestOpenFlagsGame")
        app4.launch()
        sleep(8)
        snapshot("04_FlagsGame")
        app4.terminate()

        // -------------------------------------------------------------
        // 5. Chemistry Elements Game View
        // -------------------------------------------------------------
        let app5 = XCUIApplication(bundleIdentifier: "pl.beling.ifunschool")
        setupSnapshot(app5)
        app5.launchArguments.append("-UITestOpenElementsGame")
        app5.launch()
        sleep(8)
        snapshot("05_ElementsGame")
        app5.terminate()
    }
}

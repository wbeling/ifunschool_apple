import SwiftUI

@main
struct iFunSchoolv2App: App {
    private let isTestingOrSnapshot: Bool
    @State private var isLoading: Bool

    init() {
        let args = ProcessInfo.processInfo.arguments
        let testing = args.contains("-FASTLANE_SNAPSHOT") || args.contains("-ui_testing")
        self.isTestingOrSnapshot = testing
        _isLoading = State(initialValue: !testing)

        // Trigger Game Center authentication immediately on app launch
        print("[AppLaunch][tvOS/All] App initializing. Triggering AchievementService.shared.authenticateLocalPlayer()...")
        AchievementService.shared.authenticateLocalPlayer()
    }

    var body: some Scene {
        WindowGroup("iFunSchool") {
            ZStack {
                ContentView()
                    .opacity(isLoading ? 0 : 1)

                if isLoading {
                    LoadingView()
                        .transition(.opacity.animation(.easeInOut(duration: 0.4)))
                }
            }
            .preferredColorScheme(isTestingOrSnapshot ? .light : nil)
            .onAppear {
                if !isTestingOrSnapshot {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            isLoading = false
                        }
                    }
                }
            }
        }
    }
}

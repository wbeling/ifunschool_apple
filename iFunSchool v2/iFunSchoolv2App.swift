import SwiftUI

@main
struct iFunSchoolv2App: App {
    @State private var isLoading = true

    init() {
        // Trigger Game Center authentication immediately on app launch
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
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        isLoading = false
                    }
                }
            }
        }
    }
}

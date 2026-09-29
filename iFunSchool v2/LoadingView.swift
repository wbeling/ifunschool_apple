import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            // Background
            FunColors.bgColor.ignoresSafeArea()
            VStack(spacing: 24) {
                // Centered App Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.15), radius: 16, x: 0, y: 8)

                    Image("AppLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                }
                .frame(width: 140, height: 140)
                .scaleEffect(isAnimating ? 1.04 : 0.96)
                .animation(
                    Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                    value: isAnimating
                )

                // App Title & Spinner
                VStack(spacing: 8) {
                    Text("iFunSchool")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)

                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.1)
                        .padding(.top, 4)
                }
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}

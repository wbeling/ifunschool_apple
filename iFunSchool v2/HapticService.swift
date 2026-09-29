#if(!os(macOS))
import UIKit
#endif

class HapticService {
    static let shared = HapticService()

    #if(os(iOS))
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let selectionGenerator = UISelectionFeedbackGenerator()
    #endif

    private init() {
        #if(os(iOS))
        notificationGenerator.prepare()
        impactGenerator.prepare()
        selectionGenerator.prepare()
        #endif
    }

    func playSuccess() {
        #if(os(iOS))
        notificationGenerator.notificationOccurred(.success)
        #endif
    }

    func playError() {
        #if(os(iOS))
        notificationGenerator.notificationOccurred(.error)
        #endif
    }

    func playImpact() {
        #if(os(iOS))
        impactGenerator.impactOccurred()
        #endif
    }

    func playSelection() {
        #if(os(iOS))
        selectionGenerator.selectionChanged()
        #endif
    }
}

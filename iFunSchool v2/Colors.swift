//
//  Colors.swift
//  iFunSchool
//
//  Created by Wojciech Beling on 27/07/2026.
//  Copyright © 2026 Beling.pl. All rights reserved.
//

import SwiftUI

#if os(macOS)
import AppKit

private extension Color {
    init(light: Color, dark: Color) {
        self.init(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
            let match = appearance.bestMatch(from: [.aqua, .darkAqua])
            return match == .darkAqua ? NSColor(dark) : NSColor(light)
        }))
    }
}
#elseif os(iOS) || os(tvOS)
import UIKit

private extension Color {
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}
#endif

struct FunColors {
    // Dark Chalkboard Green Accent for Shop & Unlocks (#1C6B3D)
    static let chalkboardGreen = Color(red: 0.11, green: 0.42, blue: 0.24)

    // Primary Grouped Background (iOS systemGroupedBackground: #F2F2F7 in Light, #000000 in Dark)
    static let bgColor = Color(
        light: Color(red: 242/255, green: 242/255, blue: 247/255),
        dark: Color(red: 0/255, green: 0/255, blue: 0/255)
    )

    // Secondary Grouped Background for Cards (iOS secondarySystemGroupedBackground: #FFFFFF in Light, #1C1C1E in Dark)
    static let bgColor2 = Color(
        light: Color(red: 255/255, green: 255/255, blue: 255/255),
        dark: Color(red: 28/255, green: 28/255, blue: 30/255)
    )

    // Tertiary Grouped Background for Elevated Cards (iOS tertiarySystemGroupedBackground: #F2F2F7 in Light, #2C2C2E in Dark)
    static let bgColor3 = Color(
        light: Color(red: 242/255, green: 242/255, blue: 247/255),
        dark: Color(red: 44/255, green: 44/255, blue: 46/255)
    )

    // Fill Color for Chips / Buttons (iOS tertiarySystemFill: 12% in Light, 24% in Dark)
    static let fillColor = Color(
        light: Color(red: 118/255, green: 118/255, blue: 128/255, opacity: 0.12),
        dark: Color(red: 118/255, green: 118/255, blue: 128/255, opacity: 0.24)
    )
}

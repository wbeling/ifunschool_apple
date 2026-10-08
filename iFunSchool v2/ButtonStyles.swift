//
//  ButtonStyles.swift
//  iFunSchool
//
//  Created by Wojciech Beling on 28/07/2026.
//  Copyright © 2026 Beling.pl. All rights reserved.
//

import SwiftUI

// MARK: - Dedicated tvOS Border Button Style
struct TVOSButtonStyle: ButtonStyle {
    var cornerRadius: CGFloat = 12
    var lineWidth: CGFloat = 1.0

    func makeBody(configuration: Configuration) -> some View {
        TVOSButtonBody(configuration: configuration, cornerRadius: cornerRadius, lineWidth: lineWidth)
    }
}

private struct TVOSButtonBody: View {
    let configuration: ButtonStyle.Configuration
    let cornerRadius: CGFloat
    let lineWidth: CGFloat

    @Environment(\.isFocused) private var isFocused
    @Environment(\.colorScheme) private var colorScheme

    private var borderColor: Color {
        if isFocused {
            return colorScheme == .dark ? .white : .black
        } else {
            return Color.gray.opacity(0.35)
        }
    }

    var body: some View {
        configuration.label
            .scaleEffect(isFocused ? 1.04 : (configuration.isPressed ? 0.96 : 1.0))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: lineWidth)
            )
            .animation(.easeInOut(duration: 0.15), value: isFocused)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Filter Chip Button Style
struct FunChipButtonStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        FunChipButtonBody(configuration: configuration, isSelected: isSelected)
    }
}

private struct FunChipButtonBody: View {
    let configuration: ButtonStyle.Configuration
    let isSelected: Bool
    @Environment(\.isFocused) private var isFocused
    @Environment(\.colorScheme) private var colorScheme

    private var borderColor: Color {
        #if os(tvOS)
        return isFocused ? (colorScheme == .dark ? .white : .black) : Color.gray.opacity(0.35)
        #else
        return isFocused ? (isSelected ? Color.white : Color.blue) : Color.clear
        #endif
    }

    private var borderWidth: CGFloat {
        #if os(tvOS)
        return 1.0
        #else
        return isFocused ? 2.5 : 0
        #endif
    }

    var body: some View {
        configuration.label
            .scaleEffect(isFocused ? 1.08 : (configuration.isPressed ? 0.95 : 1.0))
            .shadow(color: isFocused ? Color.blue.opacity(0.5) : Color.clear, radius: isFocused ? 6 : 0)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .animation(.easeInOut(duration: 0.15), value: isFocused)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Action Button Style (Start Game, Play Again, Unlock in Shop)
struct FunActionButtonStyle: ButtonStyle {
    var cornerRadius: CGFloat = 12

    func makeBody(configuration: Configuration) -> some View {
        FunActionButtonBody(configuration: configuration, cornerRadius: cornerRadius)
    }
}

private struct FunActionButtonBody: View {
    let configuration: ButtonStyle.Configuration
    let cornerRadius: CGFloat
    @Environment(\.isFocused) private var isFocused
    @Environment(\.colorScheme) private var colorScheme

    private var borderColor: Color {
        #if os(tvOS)
        return isFocused ? (colorScheme == .dark ? .white : .black) : Color.gray.opacity(0.35)
        #else
        return isFocused ? Color.white : Color.clear
        #endif
    }

    private var borderWidth: CGFloat {
        #if os(tvOS)
        return 1.0
        #else
        return isFocused ? 2.5 : 0
        #endif
    }

    var body: some View {
        configuration.label
            //.scaleEffect(isFocused ? 1.04 : (configuration.isPressed ? 0.96 : 1.0))
            .shadow(color: isFocused ? Color.blue.opacity(0.6) : Color.black.opacity(0.1), radius: isFocused ? 8 : 2, y: isFocused ? 4 : 1)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .animation(.easeInOut(duration: 0.15), value: isFocused)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Game Answer Option Button Style
struct FunAnswerButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        FunAnswerButtonBody(configuration: configuration)
    }
}

private struct FunAnswerButtonBody: View {
    let configuration: ButtonStyle.Configuration
    @Environment(\.isFocused) private var isFocused
    @Environment(\.colorScheme) private var colorScheme

    private var borderColor: Color {
        #if os(tvOS)
        return isFocused ? (colorScheme == .dark ? .white : .black) : Color.gray.opacity(0.35)
        #else
        return isFocused ? Color.blue : Color.clear
        #endif
    }

    private var borderWidth: CGFloat {
        #if os(tvOS)
        return 1.0
        #else
        return isFocused ? 3 : 0
        #endif
    }

    var body: some View {
        configuration.label
//            .scaleEffect(isFocused ? 1.04 : (configuration.isPressed ? 0.96 : 1.0))
            .shadow(color: isFocused ? Color.blue.opacity(0.5) : Color.black.opacity(0.04), radius: isFocused ? 8 : 4, y: isFocused ? 4 : 2)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .animation(.easeInOut(duration: 0.15), value: isFocused)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Expandable Game Row Button Style
struct FunRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        FunRowButtonBody(configuration: configuration)
    }
}

private struct FunRowButtonBody: View {
    let configuration: ButtonStyle.Configuration
    @Environment(\.isFocused) private var isFocused
    @Environment(\.colorScheme) private var colorScheme

    private var borderColor: Color {
        #if os(tvOS)
        return isFocused ? (colorScheme == .dark ? .white : .black) : Color.gray.opacity(0.35)
        #else
        return isFocused ? Color.blue : Color.clear
        #endif
    }

    private var borderWidth: CGFloat {
        #if os(tvOS)
        return 1.0
        #else
        return isFocused ? 2 : 0
        #endif
    }

    var body: some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isFocused ? FunColors.fillColor.opacity(0.8) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .scaleEffect(isFocused ? 1.02 : (configuration.isPressed ? 0.98 : 1.0))
            .animation(.easeInOut(duration: 0.15), value: isFocused)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Navigation Header Icon Button Style
struct FunHeaderButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        FunHeaderButtonBody(configuration: configuration)
    }
}

private struct FunHeaderButtonBody: View {
    let configuration: ButtonStyle.Configuration
    @Environment(\.isFocused) private var isFocused
    @Environment(\.colorScheme) private var colorScheme

    private var borderColor: Color {
        #if os(tvOS)
        return isFocused ? (colorScheme == .dark ? .white : .black) : Color.gray.opacity(0.35)
        #else
        return Color.clear
        #endif
    }

    var body: some View {
        configuration.label
            .padding(6)
            .background(
                Circle()
                    .fill(isFocused ? FunColors.fillColor : Color.clear)
            )
//            #if os(tvOS)
//            .overlay(
//                Circle()
//                    .stroke(borderColor, lineWidth: 1.0)
//            )
//            #endif
//            .scaleEffect(isFocused ? 1.15 : (configuration.isPressed ? 0.9 : 1.0))
            .animation(.easeInOut(duration: 0.15), value: isFocused)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

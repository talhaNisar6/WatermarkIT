//
//  LiquidGlassStyles.swift
//  WatermarkIT
//
//  iOS 26+ button styles — liquid glass and native press feedback.
//

import SwiftUI

// MARK: - Liquid glass (primary / secondary actions)

struct GlassCapsuleButtonStyle: ButtonStyle {
    var tint: Color?

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .glassEffect(.regular.tint(tint).interactive(true), in: .capsule)
    }
}

// MARK: - Tinted capsule (tertiary: See All, Grant Access)

struct TintedCapsuleButtonStyle: ButtonStyle {
    var tint: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(tint, in: .capsule)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Scale press (content tiles: photos, template cards)

struct ScalePressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

//
//  WatermarkConfig.swift
//  WatermarkIT
//

import SwiftUI

// MARK: - Watermark Mode
// Determines whether user is applying a text or logo watermark
// Only one mode active at a time
enum WatermarkMode: String, Codable {
    case text
    case logo
}

// MARK: - WatermarkConfig
// Core model that holds ALL watermark settings
// This struct is passed around between EditorViewModel, WatermarkRenderer, and TemplateStore
// It is Codable so it can be stored inside WatermarkTemplate via SwiftData
struct WatermarkConfig: Codable {

    // MARK: - Mode
    var mode: WatermarkMode = .text

    // MARK: - Text settings
    var text: String = "© Your Brand"
    var fontName: String = "SF Pro"        // SF Pro, Helvetica, Arial, Georgia
    var fontSize: CGFloat = 24
    var opacity: Double = 0.8              // 0.1 to 1.0
    var colorHex: String = "#FFFFFF"       // stored as hex string — Color is not Codable

    // MARK: - Position
    // Stored as percentage (0.0 to 1.0) of image width/height
    // So position works correctly on any image size
    var positionX: CGFloat = 0.85          // default bottom-right
    var positionY: CGFloat = 0.90
    var rotationDegrees: CGFloat = 0       // clockwise; e.g. -35 for diagonal

    // MARK: - Logo settings
    // Logo image is NOT stored here — UIImage is not Codable
    // It lives in EditorViewModel and is passed separately to WatermarkRenderer
    var logoScale: CGFloat = 1.0           // 0.1 to 2.0

    // MARK: - Computed helpers

    // Converts hex string back to SwiftUI Color for use in views
    var color: Color {
        Color(hex: colorHex) ?? .white
    }

    var rotationRadians: CGFloat {
        rotationDegrees * .pi / 180
    }

    // Human-readable font name → actual font
    // SF Pro is the iOS system font, accessed via .system()
    func uiFont() -> UIFont {
        switch fontName {
        case "Helvetica":   return UIFont(name: "Helvetica", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
        case "Arial":       return UIFont(name: "Arial", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
        case "Georgia":     return UIFont(name: "Georgia", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
        default:            return UIFont.systemFont(ofSize: fontSize, weight: .regular)
        }
    }
}

// MARK: - Default config factory
extension WatermarkConfig {
    // Returns a fresh default config — used when opening editor with no template
    static var defaultConfig: WatermarkConfig {
        WatermarkConfig()
    }
}

// MARK: - Color hex helper
// SwiftUI Color is not Codable, so we store colors as hex strings and convert back
extension Color {
    init?(hex: String) {
        var hexStr = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexStr = hexStr.hasPrefix("#") ? String(hexStr.dropFirst()) : hexStr

        guard hexStr.count == 6,
              let intVal = UInt64(hexStr, radix: 16) else { return nil }

        let r = Double((intVal >> 16) & 0xFF) / 255.0
        let g = Double((intVal >> 8) & 0xFF) / 255.0
        let b = Double(intVal & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }

    // Converts Color → hex string for storage
    func toHex() -> String {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X",
                      Int(r * 255),
                      Int(g * 255),
                      Int(b * 255))
    }
}

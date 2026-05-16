//
//  WatermarkTemplate.swift
//  WatermarkIT
//

import SwiftUI
import SwiftData

// MARK: - WatermarkTemplate
// SwiftData model — persisted to disk automatically
// @Model macro makes this class observable + persistable
// Think of this like CoreData's NSManagedObject but much simpler
@Model
final class WatermarkTemplate {

    // MARK: - Properties
    var id: UUID
    var name: String

    // WatermarkConfig is Codable, SwiftData stores it as encoded data automatically
    var config: WatermarkConfig

    // Built-in templates (seeded on first launch) cannot be deleted
    var isBuiltIn: Bool

    var createdAt: Date

    // Thumbnail shown on template card
    // Stored as raw PNG/JPEG data — UIImage is not directly storable in SwiftData
    var previewImageData: Data?

    // MARK: - Init
    init(
        id: UUID = UUID(),
        name: String,
        config: WatermarkConfig,
        isBuiltIn: Bool = false,
        createdAt: Date = Date(),
        previewImageData: Data? = nil
    ) {
        self.id = id
        self.name = name
        self.config = config
        self.isBuiltIn = isBuiltIn
        self.createdAt = createdAt
        self.previewImageData = previewImageData
    }

    // MARK: - Preview image helper
    // Converts stored Data back to UIImage for display in template card
    var previewImage: UIImage? {
        guard let data = previewImageData else { return nil }
        return UIImage(data: data)
    }
}

// MARK: - Built-in Templates
// These 5 templates are seeded on first launch by TemplateStore
// isBuiltIn = true means they cannot be deleted by the user
extension WatermarkTemplate {

    static var builtInTemplates: [WatermarkTemplate] {
        [
            // 1. Minimal Corner — small white text, bottom-right, low opacity
            WatermarkTemplate(
                name: "Minimal Corner",
                config: WatermarkConfig(
                    mode: .text,
                    text: "© Your Brand",
                    fontName: "SF Pro",
                    fontSize: 14,
                    opacity: 0.4,
                    colorHex: "#FFFFFF",
                    positionX: 0.85,
                    positionY: 0.90
                ),
                isBuiltIn: true
            ),

            // 2. Center Bold — large bold, center, high opacity
            WatermarkTemplate(
                name: "Center Bold",
                config: WatermarkConfig(
                    mode: .text,
                    text: "© Your Brand",
                    fontName: "SF Pro",
                    fontSize: 48,
                    opacity: 0.9,
                    colorHex: "#FFFFFF",
                    positionX: 0.5,
                    positionY: 0.5
                ),
                isBuiltIn: true
            ),

            // 3. Subtle Diagonal — rotated text, center, very low opacity
            WatermarkTemplate(
                name: "Subtle Diagonal",
                config: WatermarkConfig(
                    mode: .text,
                    text: "© Your Brand",
                    fontName: "Helvetica",
                    fontSize: 20,
                    opacity: 0.2,
                    colorHex: "#FFFFFF",
                    positionX: 0.5,
                    positionY: 0.5,
                    rotationDegrees: -35
                ),
                isBuiltIn: true
            ),

            // 4. Bottom Bar — medium text, bottom-center
            WatermarkTemplate(
                name: "Bottom Bar",
                config: WatermarkConfig(
                    mode: .text,
                    text: "© Your Brand",
                    fontName: "Arial",
                    fontSize: 18,
                    opacity: 0.85,
                    colorHex: "#FFFFFF",
                    positionX: 0.5,
                    positionY: 0.92
                ),
                isBuiltIn: true
            ),

            // 5. Studio 2026 — small colored text, top-left
            WatermarkTemplate(
                name: "Studio 2026",
                config: WatermarkConfig(
                    mode: .text,
                    text: "© Studio 2026",
                    fontName: "Georgia",
                    fontSize: 13,
                    opacity: 0.75,
                    colorHex: "#A78BFA",
                    positionX: 0.15,
                    positionY: 0.08
                ),
                isBuiltIn: true
            )
        ]
    }
}

//
//  ExportOptions.swift
//  WatermarkIT
//

import Foundation

// MARK: - Export Quality
enum ExportQuality: String, CaseIterable, Identifiable {
    case high   = "High"
    case medium = "Medium"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .high:   return "Best quality"
        case .medium: return "Balanced, smaller file size"
        }
    }

    // JPEG compression value (1.0 = max quality, 0.0 = max compression)
    var compressionValue: CGFloat {
        switch self {
        case .high:   return 1.0
        case .medium: return 0.6
        }
    }
}

// MARK: - Export Format
enum ExportFormat: String, CaseIterable, Identifiable {
    case jpeg = "JPEG"
    case png  = "PNG"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .jpeg: return "Smaller file size"
        case .png:  return "Better for logos with transparency"
        }
    }
}

// MARK: - ExportOptions
// Passed to WatermarkRenderer and PhotoLibraryService when exporting
struct ExportOptions {
    var quality: ExportQuality = .high
    var format: ExportFormat   = .jpeg
}

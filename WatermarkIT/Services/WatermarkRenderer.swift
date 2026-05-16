//
//  WatermarkRenderer.swift
//  WatermarkIT
//

import UIKit

// MARK: - WatermarkRenderer

/// Renders a watermarked image using `UIGraphicsImageRenderer` for export-quality output.
enum WatermarkRenderer {

    /// Renders `image` with the watermark described by `config`.
    /// - Parameters:
    ///   - image: Source photo (orientation is respected).
    ///   - config: Text or logo settings; `positionX` / `positionY` are the watermark center (0…1).
    ///   - logo: Required when `config.mode == .logo`.
    static func render(
        image: UIImage,
        config: WatermarkConfig,
        logo: UIImage? = nil
    ) -> UIImage {
        let size = image.size
        guard size.width > 0, size.height > 0 else { return image }

        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale
        format.opaque = true

        let renderer = UIGraphicsImageRenderer(size: size, format: format)

        return renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: size))

            switch config.mode {
            case .text:
                drawText(config: config, canvasSize: size, in: context.cgContext)
            case .logo:
                guard let logo else { return }
                drawLogo(logo, config: config, canvasSize: size, in: context.cgContext)
            }
        }
    }

    /// Smaller render for template cards and previews.
    static func renderThumbnail(
        image: UIImage,
        config: WatermarkConfig,
        logo: UIImage? = nil,
        maxPixelSize: CGFloat = 260
    ) -> UIImage {
        let scaled = image.scaledToFit(maxPixelSize: maxPixelSize)
        return render(image: scaled, config: config, logo: logo)
    }

    /// Neutral sample used for template previews on Home / Templates.
    static var previewSampleImage: UIImage {
        if let cached = PreviewSampleCache.image { return cached }
        let size = CGSize(width: 400, height: 300)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 2
        format.opaque = true
        let image = UIGraphicsImageRenderer(size: size, format: format).image { context in
            let rect = CGRect(origin: .zero, size: size)
            UIColor.systemGray3.setFill()
            context.fill(rect)
            UIColor.systemGray2.setFill()
            context.fill(CGRect(x: size.width * 0.55, y: size.height * 0.3, width: size.width * 0.45, height: size.height * 0.7))
        }
        PreviewSampleCache.image = image
        return image
    }

    // MARK: - Text

    private static func drawText(
        config: WatermarkConfig,
        canvasSize: CGSize,
        in context: CGContext
    ) {
        let trimmed = config.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let attributes: [NSAttributedString.Key: Any] = [
            .font: config.uiFont(),
            .foregroundColor: config.uiColor.withAlphaComponent(CGFloat(config.opacity)),
        ]
        let attributed = NSAttributedString(string: trimmed, attributes: attributes)
        let textSize = attributed.size()
        let center = centerForWatermark(
            canvasSize: canvasSize,
            positionX: config.positionX,
            positionY: config.positionY
        )

        context.saveGState()
        context.translateBy(x: center.x, y: center.y)
        if config.rotationDegrees != 0 {
            context.rotate(by: config.rotationRadians)
        }
        attributed.draw(at: CGPoint(x: -textSize.width / 2, y: -textSize.height / 2))
        context.restoreGState()
    }

    // MARK: - Logo

    private static func drawLogo(
        _ logo: UIImage,
        config: WatermarkConfig,
        canvasSize: CGSize,
        in context: CGContext
    ) {
        let logoSize = logoDrawSize(logo: logo, canvasSize: canvasSize, scale: config.logoScale)
        let center = centerForWatermark(
            canvasSize: canvasSize,
            positionX: config.positionX,
            positionY: config.positionY
        )

        context.saveGState()
        context.translateBy(x: center.x, y: center.y)
        if config.rotationDegrees != 0 {
            context.rotate(by: config.rotationRadians)
        }
        let rect = CGRect(
            x: -logoSize.width / 2,
            y: -logoSize.height / 2,
            width: logoSize.width,
            height: logoSize.height
        )
        logo.draw(in: rect, blendMode: .normal, alpha: CGFloat(config.opacity))
        context.restoreGState()
    }

    /// Base width ≈ 25% of the shorter image side, multiplied by `logoScale` (0.1…2).
    private static func logoDrawSize(logo: UIImage, canvasSize: CGSize, scale: CGFloat) -> CGSize {
        let clampedScale = min(max(scale, 0.1), 2.0)
        let base = min(canvasSize.width, canvasSize.height) * 0.25 * clampedScale
        let aspect = logo.size.height > 0 ? logo.size.width / logo.size.height : 1
        if aspect >= 1 {
            return CGSize(width: base, height: base / aspect)
        }
        return CGSize(width: base * aspect, height: base)
    }

    /// `positionX` / `positionY` mark the center of the watermark (0…1).
    private static func centerForWatermark(
        canvasSize: CGSize,
        positionX: CGFloat,
        positionY: CGFloat
    ) -> CGPoint {
        CGPoint(
            x: canvasSize.width * min(max(positionX, 0), 1),
            y: canvasSize.height * min(max(positionY, 0), 1)
        )
    }
}

// MARK: - Preview sample cache

private enum PreviewSampleCache {
    static var image: UIImage?
}

// MARK: - UIImage scaling

private extension UIImage {
    func scaledToFit(maxPixelSize: CGFloat) -> UIImage {
        let longest = max(size.width, size.height)
        guard longest > maxPixelSize else { return self }

        let scale = maxPixelSize / longest
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true

        return UIGraphicsImageRenderer(size: newSize, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

// MARK: - WatermarkConfig (UIKit)

extension WatermarkConfig {
    var uiColor: UIColor {
        UIColor(color)
    }
}

#if DEBUG
import SwiftUI

#Preview("Subtle Diagonal") {
    let config = WatermarkTemplate.builtInTemplates[0].config
    let result = WatermarkRenderer.render(
        image: WatermarkRenderer.previewSampleImage,
        config: config
    )
    Image(uiImage: result)
        .resizable()
        .scaledToFit()
        .padding()
}

#Preview("Minimal Corner") {
    let config = WatermarkTemplate.builtInTemplates[1].config
    let result = WatermarkRenderer.render(
        image: WatermarkRenderer.previewSampleImage,
        config: config
    )
    Image(uiImage: result)
        .resizable()
        .scaledToFit()
        .padding()
}
#endif

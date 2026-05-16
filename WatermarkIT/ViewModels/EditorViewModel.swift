//
//  EditorViewModel.swift
//  WatermarkIT
//

import UIKit

@Observable
final class EditorViewModel {

    let sourceImage: UIImage
    var config: WatermarkConfig
    var logoImage: UIImage?

    private(set) var previewImage: UIImage

    init(image: UIImage, template: WatermarkTemplate?) {
        sourceImage = image
        config = template?.config ?? .defaultConfig
        previewImage = image
        refreshPreview()
    }

    func refreshPreview() {
        previewImage = WatermarkRenderer.renderThumbnail(
            image: sourceImage,
            config: config,
            logo: logoImage,
            maxPixelSize: 1600
        )
    }
}

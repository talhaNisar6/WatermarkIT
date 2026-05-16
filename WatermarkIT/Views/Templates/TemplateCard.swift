//
//  TemplateCard.swift
//  WatermarkIT
//

import SwiftUI

struct TemplateCard: View {
    let template: WatermarkTemplate

    private let previewImage: UIImage

    init(template: WatermarkTemplate) {
        self.template = template
        self.previewImage = WatermarkRenderer.renderThumbnail(
            image: WatermarkRenderer.previewSampleImage,
            config: template.config
        )
    }

    var body: some View {
        VStack(spacing: 4) {
            Image(uiImage: previewImage)
                .resizable()
                .scaledToFill()
                .frame(width: 130, height: 98)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(template.name)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .frame(width: 130)
        }
    }
}

#Preview {
    TemplateCard(template: WatermarkTemplate.builtInTemplates[0])
}

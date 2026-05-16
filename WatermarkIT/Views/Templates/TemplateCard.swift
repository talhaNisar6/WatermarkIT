//
//  TemplateCard.swift
//  WatermarkIT
//

import SwiftUI

struct TemplateCard: View {
    let template: WatermarkTemplate

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray))
                    .frame(width: 130, height: 98)

                Text(template.config.text)
                    .font(.system(size: max(template.config.fontSize * 0.25, 8)))
                    .foregroundStyle(template.config.color)
                    .opacity(template.config.opacity)
            }

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

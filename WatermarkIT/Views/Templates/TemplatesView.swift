//
//  TemplatesView.swift
//  WatermarkIT
//
//  Created by Talha Nisar on 16/05/2026.
//

import SwiftUI

struct TemplatesView: View {
    var onTemplateSelected: ((WatermarkTemplate) -> Void)? = nil

    var body: some View {
        Text("Templates — Phase 5")
            .navigationTitle("Templates")
            .navigationBarTitleDisplayMode(.inline)
    }
}

//
//  EditorView.swift
//  WatermarkIT
//
//  Created by Talha Nisar on 16/05/2026.
//

import SwiftUI

struct EditorView: View {
    let image: UIImage
    var template: WatermarkTemplate?

    var body: some View {
        Text("Editor — Phase 4")
            .navigationTitle("Edit Watermark")
            .navigationBarTitleDisplayMode(.inline)
    }
}

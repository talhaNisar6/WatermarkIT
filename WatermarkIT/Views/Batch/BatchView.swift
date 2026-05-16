//
//  BatchView.swift
//  WatermarkIT
//
//  Created by Talha Nisar on 16/05/2026.
//

import SwiftUI

struct BatchView: View {
    let images: [UIImage]

    var body: some View {
        Text("Batch — Phase 6")
            .navigationTitle("Batch — \(images.count) Photos")
            .navigationBarTitleDisplayMode(.inline)
    }
}

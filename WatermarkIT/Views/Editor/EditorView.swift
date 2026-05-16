//
//  EditorView.swift
//  WatermarkIT
//

import SwiftUI

struct EditorView: View {

    @State private var viewModel: EditorViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showDiscardAlert = false

    init(image: UIImage, template: WatermarkTemplate?) {
        _viewModel = State(initialValue: EditorViewModel(image: image, template: template))
    }

    var body: some View {
        previewCanvas
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Edit Watermark")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showDiscardAlert = true
                    }
                }
            }
            .alert("Discard Changes?", isPresented: $showDiscardAlert) {
                Button("Keep Editing", role: .cancel) {}
                Button("Discard", role: .destructive) {
                    dismiss()
                }
            } message: {
                Text("Your watermark edits will be lost.")
            }
    }

    private var previewCanvas: some View {
        GeometryReader { geometry in
            Image(uiImage: viewModel.previewImage)
                .resizable()
                .scaledToFit()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
        }
        .padding(16)
    }
}

#Preview {
    NavigationStack {
        EditorView(
            image: WatermarkRenderer.previewSampleImage,
            template: WatermarkTemplate.builtInTemplates[0]
        )
    }
}

//
//  ImagePicker.swift
//  WatermarkIT
//
//  Created by Talha Nisar on 16/05/2026.
//

import SwiftUI
import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {

    var selectionLimit: Int = 1
    var onSelect: ([UIImage]) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = selectionLimit
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onSelect: onSelect)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let onSelect: ([UIImage]) -> Void

        init(onSelect: @escaping ([UIImage]) -> Void) {
            self.onSelect = onSelect
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            var images: [UIImage] = []
            let group = DispatchGroup()

            for result in results {
                group.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { object, _ in
                    if let image = object as? UIImage {
                        images.append(image)
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                self.onSelect(images)
            }
        }
    }
}

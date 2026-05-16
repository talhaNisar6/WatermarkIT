//
//  HomeViewModel.swift
//  WatermarkIT
//
//  Created by Talha Nisar on 16/05/2026.
//

import SwiftUI
import Photos

@Observable
class HomeViewModel {

    var recentPhotos: [UIImage] = []
    var photoPermissionStatus: PHAuthorizationStatus = .notDetermined
    var showPermissionDeniedAlert = false

    init() {
        photoPermissionStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        if photoPermissionStatus == .authorized || photoPermissionStatus == .limited {
            loadRecentPhotos()
        }
    }

    func requestPhotoPermission() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
            DispatchQueue.main.async {
                self?.photoPermissionStatus = status
                if status == .authorized || status == .limited {
                    self?.loadRecentPhotos()
                }
            }
        }
    }

    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    private func loadRecentPhotos() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 6

        let results = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat

        var photos: [UIImage] = []
        results.enumerateObjects { asset, _, _ in
            manager.requestImage(for: asset,
                                 targetSize: CGSize(width: 300, height: 300),
                                 contentMode: .aspectFill,
                                 options: options) { [weak self] image, _ in
                if let image {
                    DispatchQueue.main.async {
                        photos.append(image)
                        self?.recentPhotos = photos
                    }
                }
            }
        }
    }
}

//
//  HomeView.swift
//  WatermarkIT
//

import SwiftUI
import Photos

struct HomeView: View {

    @State private var viewModel = HomeViewModel()
    @State private var showSinglePicker = false
    @State private var showBatchPicker = false
    @State private var navigateToEditor = false
    @State private var navigateToBatch = false
    @State private var navigateToTemplates = false
    @State private var selectedImage: UIImage?
    @State private var selectedBatchImages: [UIImage] = []
    @State private var selectedTemplate: WatermarkTemplate?

    private let builtInTemplates = WatermarkTemplate.builtInTemplates

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    actionButtons
                    featuredTemplatesSection
                    recentPhotosSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 24)
            }
            .navigationDestination(isPresented: $navigateToEditor) {
                if let image = selectedImage {
                    EditorView(image: image, template: selectedTemplate)
                }
            }
            .navigationDestination(isPresented: $navigateToBatch) {
                BatchView(images: selectedBatchImages)
            }
            .navigationDestination(isPresented: $navigateToTemplates) {
                TemplatesView()
            }
            .sheet(isPresented: $showSinglePicker) {
                ImagePicker(selectionLimit: 1) { images in
                    guard let image = images.first else { return }
                    selectedImage = image
                    navigateToEditor = true
                }
            }
            .sheet(isPresented: $showBatchPicker) {
                ImagePicker(selectionLimit: 10) { images in
                    if images.count > 10 {
                        selectedBatchImages = Array(images.prefix(10))
                    } else {
                        selectedBatchImages = images
                        if !selectedBatchImages.isEmpty {
                            navigateToBatch = true
                        }
                    }
                }
            }
            .navigationTitle("WatermarkIt")
            .navigationBarTitleDisplayMode(.large)
            
        }
        
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                showSinglePicker = true
            } label: {
                Label("Pick a Photo", systemImage: "photo")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
                    .clipShape(RoundedRectangle(cornerRadius: 26))
            }

            Button {
                showBatchPicker = true
            } label: {
                Label("Batch Import", systemImage: "square.stack")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundStyle(.primary)
                    .fontWeight(.semibold)
                    .clipShape(RoundedRectangle(cornerRadius: 26))
                    .overlay(
                        RoundedRectangle(cornerRadius: 26)
                            .stroke(Color.primary.opacity(0.2), lineWidth: 1.5)
                    )
            }
        }
    }

    private var featuredTemplatesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Featured Templates")
                    .font(.headline)
                Spacer()
                Button("See All") {
                    navigateToTemplates = true
                }
                .font(.subheadline)
                .foregroundStyle(.purple)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(builtInTemplates, id: \.id) { template in
                        TemplateCard(template: template)
                            .onTapGesture {
                                selectedTemplate = template
                                showSinglePicker = true
                            }
                    }
                }
                .padding(.bottom, 4)
            }
        }
    }

    private var recentPhotosSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Photos")
                .font(.headline)

            switch viewModel.photoPermissionStatus {
            case .notDetermined:
                permissionPlaceholder
            case .denied, .restricted:
                deniedPlaceholder
            case .authorized, .limited:
                if viewModel.recentPhotos.isEmpty {
                    Text("No photos in your library yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 24)
                } else {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 3), spacing: 4) {
                        ForEach(Array(viewModel.recentPhotos.enumerated()), id: \.offset) { _, photo in
                            Image(uiImage: photo)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 110, height: 110)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .onTapGesture {
                                    selectedImage = photo
                                    selectedTemplate = nil
                                    navigateToEditor = true
                                }
                        }
                    }
                }
            @unknown default:
                EmptyView()
            }
        }
    }

    private var permissionPlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "lock.fill")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("Allow access to see recent photos")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Grant Access") {
                viewModel.requestPhotoPermission()
            }
            .buttonStyle(.borderedProminent)
            .tint(.purple)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var deniedPlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "lock.slash.fill")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("Photo access denied")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("Open Settings") {
                viewModel.openSettings()
            }
            .buttonStyle(.borderedProminent)
            .tint(.purple)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct TemplateCard: View {
    let template: WatermarkTemplate

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.systemGray))
                    .frame(width: 130, height: 90)

                Text(template.config.text)
                    .font(.system(size: max(template.config.fontSize * 0.25, 8)))
                    .foregroundStyle(template.config.color)
                    .opacity(template.config.opacity)
            }

            Text(template.name)
                .padding(.leading, 6)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .frame(width: 130, alignment: .leading)
                
        }
    }
}

#Preview {
    HomeView()
}

//
//  HomeView.swift
//  WatermarkIT
//

import SwiftUI
import Photos

// MARK: - HomeView

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
                .background(Color.clear)
                .padding(.horizontal, 16)
                .padding(.top, 24)
                .padding(.bottom, 34)
            }
            .background(Color(.systemGroupedBackground))
            .scrollIndicators(.hidden)
            .navigationTitle("WatermarkIt")
            .navigationBarTitleDisplayMode(.large)
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
                    selectedBatchImages = Array(images.prefix(10))
                    if !selectedBatchImages.isEmpty {
                        navigateToBatch = true
                    }
                }
            }
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                showSinglePicker = true
            } label: {
                Label("Pick a Photo", systemImage: "photo")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
                    .background(
                        LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                    )
                    .clipShape(.capsule)
            }
            .buttonStyle(GlassCapsuleButtonStyle())

            Button {
                showBatchPicker = true
            } label: {
                Label("Batch Import", systemImage: "square.stack")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundStyle(.primary)
                    .fontWeight(.semibold)
            }
            .buttonStyle(GlassCapsuleButtonStyle())
        }
    }

    // MARK: - Featured Templates

    private var featuredTemplatesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Featured Templates")
                    .font(.headline)
                Spacer()
                Button {
                    navigateToTemplates = true
                } label: {
                    HStack(spacing: 4) {
                        Text("See All")
                            .font(.subheadline.weight(.medium))
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(.purple)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                }
                .buttonStyle(TintedCapsuleButtonStyle(tint: .purple.opacity(0.08)))
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(builtInTemplates, id: \.id) { template in
                        Button {
                            selectedTemplate = template
                            showSinglePicker = true
                        } label: {
                            TemplateCard(template: template)
                                .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
                        }
                        .buttonStyle(ScalePressButtonStyle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 6)
                .padding(.top, 4)
            }
            .padding(.horizontal, -16)
        }
    }

    // MARK: - Recent Photos

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
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 100, maximum: 120), spacing: 8)],
                        spacing: 8
                    ) {
                        ForEach(Array(viewModel.recentPhotos.enumerated()), id: \.offset) { _, photo in
                            GeometryReader { geo in
                                Button {
                                    selectedImage = photo
                                    selectedTemplate = nil
                                    navigateToEditor = true
                                } label: {
                                    Image(uiImage: photo)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: geo.size.width, height: geo.size.width)
                                        .clipped()
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                }
                                .buttonStyle(ScalePressButtonStyle())
                            }
                            .aspectRatio(1, contentMode: .fit)
                        }
                    }
                }
            @unknown default:
                EmptyView()
            }
        }
    }

    // MARK: - Permission Placeholders

    private var permissionPlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "lock.fill")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("Allow access to see recent photos")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button {
                viewModel.requestPhotoPermission()
            } label: {
                Text("Grant Access")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.purple)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
            }
            .buttonStyle(TintedCapsuleButtonStyle(tint: .purple.opacity(0.08)))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(Color(.systemGray4))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
    }

    private var deniedPlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "lock.slash.fill")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("Photo access denied")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button {
                viewModel.openSettings()
            } label: {
                Text("Open Settings")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.purple)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
            }
            .buttonStyle(TintedCapsuleButtonStyle(tint: .purple.opacity(0.08)))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(Color(.systemGray4))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
    }
}

#Preview {
    HomeView()
}

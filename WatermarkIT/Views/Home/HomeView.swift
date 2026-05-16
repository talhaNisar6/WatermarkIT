//
//  HomeView.swift
//  WatermarkIT
//

import SwiftUI
import Photos

// MARK: - Press Effect (only for non-glass elements on <iOS 26)
struct PressEffectModifier: ViewModifier {
    @State private var pressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(pressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: pressed)
            ._onButtonGesture { pressing in
                pressed = pressing
            } perform: {}
    }
}

extension View {
    func pressEffect() -> some View {
        modifier(PressEffectModifier())
    }
}

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
            .buttonStyle(glassOrPressButtonStyle())

            Button {
                showBatchPicker = true
            } label: {
                Label("Batch Import", systemImage: "square.stack")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundStyle(.primary)
                    .fontWeight(.semibold)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(.capsule)
            }
            .buttonStyle(glassOrPressButtonStyle())
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
                .buttonStyle(glassOrPressButtonStyle(tint: .purple.opacity(0.08)))
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
                           .buttonStyle(PlainPressButtonStyle())
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
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100, maximum: 120), spacing: 12)], spacing: 12) {                        ForEach(Array(viewModel.recentPhotos.enumerated()), id: \.offset) { _, photo in
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
                                .buttonStyle(PlainPressButtonStyle())
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
            .buttonStyle(glassOrPressButtonStyle(tint: .purple.opacity(0.08)))
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
            .buttonStyle(glassOrPressButtonStyle(tint: .purple.opacity(0.08)))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(Color(.systemGray4))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Glass or Press ButtonStyle
struct glassOrPressButtonStyle: ButtonStyle {
    var tint: Color?
    func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .glassEffect(.regular.tint(tint).interactive(true), in: .capsule)
    }
}
struct PlainPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - TemplateCard
struct TemplateCard: View {
    let template: WatermarkTemplate

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
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
    HomeView()
}

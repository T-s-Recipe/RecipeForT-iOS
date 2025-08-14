//
//  ImagePickerFeature.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/13/25.
//

import SwiftUI
import PhotosUI

struct ImagePickerFeature {
    @Binding var selectedImageItem: ImageItem?
    @State private var selectedItem: PhotosPickerItem?
    @State private var state = ImagePickerState()
}

// MARK: - ViewFeature Conformation
extension ImagePickerFeature: ViewFeature {
    enum UIEvent {
        case presentPickerOptionSheet
        case photoSelected(PhotosPickerItem?)
        case cameraPhotoSelected(UIImage?)
        case removeImage
    }
    
    func notify(_ event: UIEvent) {
        switch event {
        case .presentPickerOptionSheet:
            state.isPickerOptionSheetPresented.toggle()
        case .photoSelected(let photosPickerItem):
            updateSelectedItem(item: photosPickerItem)
        case .cameraPhotoSelected(let uIImage):
            updateSelectedItem(uiImage: uIImage)
        case .removeImage:
            removePhoto()
        }
    }
}

// MARK: - View Conformation
extension ImagePickerFeature: View {
    var body: some View {
        VStack(spacing: 12) {
            switch state.entity {
            case .idle:
                defaultImage

            case .selected(let item):
                if let uiImage = UIImage(data: item.data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 60)
                        .overlay(alignment: .topTrailing) {
                            removeButton
                        }
                } else {
                    defaultImage
                }
            }
        }
        .photosPicker(isPresented: $state.isPhotoPickerPresented, selection: $selectedItem, matching: .images)
        .onChange(of: selectedItem) { _, newValue in
            notify(.photoSelected(newValue))
        }
        .sheet(isPresented: $state.isPickerOptionSheetPresented) {
            SelectPickerOptionFeature(state: state)
        }
        .fullScreenCover(isPresented: $state.isCameraPickerPresented) {
            CameraPicker { notify(.cameraPhotoSelected($0)) }
                .ignoresSafeArea()
        }
    }
    
    private var defaultImage: some View {
        Button {
            notify(.presentPickerOptionSheet)
        } label: {
            RoundedRectangle(cornerRadius: 5)
                .fill(.clear)
                .strokeBorder(.gray)
                .frame(width: 80, height: 60)
                .overlay {
                    Image(systemName: "camera.fill")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .padding(16)
                        .foregroundStyle(.gray)
                }
        }
    }
    
    private var removeButton: some View {
        Button {
            notify(.removeImage)
        } label: {
            Image(systemName: "xmark.circle.fill")
                .frame(width: 20, height: 20)
                .foregroundStyle(.white)
                .background(Circle().fill(.black))
        }
    }
}

// MARK: - Methods
private extension ImagePickerFeature {
    func updateSelectedItem(item: PhotosPickerItem?) {
        state.cancelTask(for: #function)
        
        let task = Task {
            do {
                guard let data = try await item?.loadTransferable(type: Data.self),
                      let utType = item?.supportedContentTypes.first
                else { return selectedImageItem = nil }
                let mimeTypeString = utType.identifier
                let name = item?.itemIdentifier ?? "photo"
                let imageItem = ImageItem(data: data, mimeType: mimeTypeString, filename: name)
                state.entity = .selected(imageItem)
                selectedImageItem = imageItem
            } catch {
                selectedImageItem = nil
            }
        }
        
        state.storeTask(for: #function, task: task)
    }
    
    func updateSelectedItem(uiImage: UIImage?) {
        state.cancelTask(for: #function)
        
        let task = Task {
            guard let image = uiImage,
                  let data = image.jpegData(compressionQuality: 0.8)
            else { return selectedImageItem = nil }
            let mimeTypeString = "jpeg"
            let name = "photo"
            let imageItem = ImageItem(data: data, mimeType: mimeTypeString, filename: name)
            state.entity = .selected(imageItem)
            selectedImageItem = imageItem
        }
        
        state.storeTask(for: #function, task: task)
    }
    
    func removePhoto() {
        state.entity = .idle
        selectedImageItem = nil
    }
}

// MARK: - Subviews
struct SelectPickerOptionFeature {
    @Bindable var state: ImagePickerState
}

extension SelectPickerOptionFeature: ViewFeature {
    enum UIEvent {
        case selectPhotoLibrary
        case selectCamera
    }
    
    func notify(_ event: UIEvent) {
        switch event {
        case .selectPhotoLibrary:
            state.isPickerOptionSheetPresented.toggle()
            state.isPhotoPickerPresented.toggle()
        case .selectCamera:
            state.isPickerOptionSheetPresented.toggle()
            state.isCameraPickerPresented.toggle()
        }
    }
}

extension SelectPickerOptionFeature: View {
    var body: some View {
        HStack(spacing: 16) {
            Button {
                notify(.selectPhotoLibrary)
            } label: {
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.secondary)
            }
            
            Button {
                notify(.selectCamera)
            } label: {
                Image(systemName: "camera")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.secondary)
            }
        }
        .presentationDetents([.medium])
        .presentationCornerRadius(16)
        .presentationDragIndicator(.visible)
    }
}

struct CameraPicker: UIViewControllerRepresentable {
    typealias Handler = (UIImage?) -> Void
    
    let onSelect: Handler
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onSelect: onSelect)
    }
    
    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        private let onSelect: Handler
        
        init(onSelect: @escaping Handler) {
            self.onSelect = onSelect
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let image = info[.originalImage] as? UIImage
            onSelect(image)
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            onSelect(nil)
            picker.dismiss(animated: true)
        }
    }
}

#Preview {
    EditRecipeFeature(recipe: nil)
}

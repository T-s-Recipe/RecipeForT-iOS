//
//  ImagePickerFeature.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/13/25.
//

import SwiftUI
import PhotosUI
import ComposableArchitecture

@Reducer
struct ImagePickerFeature {
    @ObservableState
    struct State: Equatable {
        var selectedImage: ImageItem?
        var isProcessing: Bool = false
        
        @Presents var destination: Destination.State?
    }
    
    enum Action {
        @CasePathable
        enum ViewAction {
            case selectButtonTapped
            case removeButtonTapped
            case photoPickerResult(PhotosPickerItem?)
            case cameraResult(UIImage?)
            case setDestination(Destination.State?)
        }
        
        @CasePathable
        enum InternalAction {
            case convertImageResponse(ImageItem?)
        }
        
        @CasePathable
        enum Delegate {
            case didSelectImage(ImageItem?)
        }
        
        case view(ViewAction)
        case `internal`(InternalAction)
        case delegate(Delegate)
        case destination(PresentationAction<Destination.Action>)
    }
    
    @Reducer
    struct Destination {
        @ObservableState
        enum State: Equatable {
            case options(Options.State = .init())
            case photoPicker(PhotoPicker.State = .init())
            case camera(Camera.State = .init())
        }
        
        enum Action {
            case options(Options.Action)
            case photoPicker(PhotoPicker.Action)
            case camera(Camera.Action)
        }
        
        @Reducer
        struct Options {
            @ObservableState struct State: Equatable {}
            enum Action {
                case libraryButtonTapped
                case cameraButtonTapped
            }
            var body: some Reducer<State, Action> { Reduce { _, _ in .none } }
        }
        
        @Reducer
        struct PhotoPicker {
            @ObservableState
            struct State: Equatable {}
            
            enum Action {}
            
            var body: some Reducer<State, Action> {
                EmptyReducer()
            }
        }
        
        @Reducer
        struct Camera {
            @ObservableState
            struct State: Equatable {}
            
            enum Action {}
            
            var body: some Reducer<State, Action> {
                EmptyReducer()
            }
        }
        
        var body: some Reducer<State, Action> {
            Scope(state: \.options, action: \.options) { Options() }
            Scope(state: \.photoPicker, action: \.photoPicker) { PhotoPicker() }
            Scope(state: \.camera, action: \.camera) { Camera() }
        }
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(.selectButtonTapped):
                state.destination = .options(.init())
                return .none
                
            case .view(.removeButtonTapped):
                state.selectedImage = nil
                return .send(.delegate(.didSelectImage(nil)))
                
            case .view(.photoPickerResult(let item)):
                guard let item else { return .none }
                state.isProcessing = true
                return .run { send in
                    guard let data = try? await item.loadTransferable(type: Data.self),
                          let utType = item.supportedContentTypes.first
                    else {
                        return await send(.internal(.convertImageResponse(nil)))
                    }
                    let mimeTypeString = utType.identifier
                    let name = item.itemIdentifier ?? "photo"
                    let imageItem = ImageItem(data: data, mimeType: mimeTypeString, filename: name)
                    return await send(.internal(.convertImageResponse(imageItem)))
                }
                
            case .view(.cameraResult(let image)):
                guard let image else { return .none }
                state.isProcessing = true
                return .run { send in
                    guard let data = image.jpegData(compressionQuality: 0.8) else { return await send(.internal(.convertImageResponse(nil))) }
                    let mimeTypeString = "jpeg"
                    let name = "photo"
                    let imageItem = ImageItem(data: data, mimeType: mimeTypeString, filename: name)
                    return await send(.internal(.convertImageResponse(imageItem)))
                }
                
            case .view(.setDestination(let destination)):
                state.destination = destination
                return .none
                
            case .internal(.convertImageResponse(let item)):
                state.isProcessing = false
                return .send(.delegate(.didSelectImage(item)))
                
            case .destination(.presented(.options(.libraryButtonTapped))):
                state.destination = .photoPicker(.init())
                return .none
                
            case .destination(.presented(.options(.cameraButtonTapped))):
                state.destination = .camera(.init())
                return .none
                
            case .destination(.dismiss):
                state.destination = nil
                return .none
                
            case .delegate:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination) { Destination() }
    }
}

struct ImagePickerView: View {
    @Bindable var store: StoreOf<ImagePickerFeature>
    
    var body: some View {
        VStack(spacing: 12) {
            if let imageItem = store.selectedImage, let uiImage = UIImage(data: imageItem.data) {
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
        .sheet(item: $store.scope(state: \.destination?.options, action: \.destination.options)) { store in
            SelectPickerOptionView(store: store)
        }
        .fullScreenCover(item: $store.scope(state: \.destination?.camera, action: \.destination.camera)) { _ in
            CameraPicker { store.send(.view(.cameraResult($0))) }
                .ignoresSafeArea()
        }
        .photosPicker(
            isPresented: .init(
                get: { store.destination?.photoPicker != nil },
                set: { if $0 == false { store.send(.view(.setDestination(nil))) } }
            ),
            selection: .init(
                get: { nil },
                set: { store.send(.view(.photoPickerResult($0))) }
            )
        )
    }
    
    private var defaultImage: some View {
        Button {
            
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
            
        } label: {
            Image(systemName: "xmark.circle.fill")
                .frame(width: 20, height: 20)
                .foregroundStyle(.white)
                .background(Circle().fill(.black))
        }
    }
}

struct SelectPickerOptionView: View {
    let store: StoreOf<ImagePickerFeature.Destination.Options>
    
    var body: some View {
        HStack(spacing: 16) {
            Button {
                store.send(.libraryButtonTapped)
            } label: {
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.secondary)
            }
            
            Button {
                store.send(.cameraButtonTapped)
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

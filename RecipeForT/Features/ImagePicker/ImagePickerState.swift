//
//  ImagePickerState.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/13/25.
//

import Foundation
import UniformTypeIdentifiers

@Observable
final class ImagePickerState: ViewState {
    enum Entity: Equatable {
        case idle
        case selected(ImageItem)
    }
    
    var entity: Entity = .idle
    var isPickerOptionSheetPresented: Bool = false
    var isPhotoPickerPresented: Bool = false
    var isCameraPickerPresented: Bool = false
    
    var tasks: [String: Task<Void, Never>] = [:]
}

// MARK: - Interfaces
extension ImagePickerState {
    
}

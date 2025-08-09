//
//  RecipeBaseInfoViewModel.swift
//  RecipeForT
//
//  Created by Swain Yun on 7/23/25.
//

import Foundation

protocol RecipeBaseInfoViewModelDelegate: AnyObject {
    var titleText: String { get set }
    var servingsText: String { get set }
    var costText: String { get set }
    var timeText: String { get set }
    var notesText: String { get set }
    var isServingsTextFieldDisabled: Bool { get set }
    var isCostTextFieldDisabled: Bool { get set }
    var isTimeTextFieldDisabled: Bool { get set }
}

@Observable @MainActor
final class RecipeBaseInfoViewModel {
    var titleText: String {
        get { delegate?.titleText ?? "" }
        set { delegate?.titleText = newValue }
    }
    var servingsText: String {
        get { delegate?.servingsText ?? "" }
        set { delegate?.servingsText = newValue }
    }
    var costText: String {
        get { delegate?.costText ?? "" }
        set { delegate?.costText = newValue }
    }
    var timeText: String {
        get { delegate?.timeText ?? "" }
        set { delegate?.timeText = newValue }
    }
    var notesText: String {
        get { delegate?.notesText ?? "" }
        set { delegate?.notesText = newValue }
    }
    var isServingsTextFieldDisabled: Bool {
        get { delegate?.isCostTextFieldDisabled ?? true }
        set { delegate?.isCostTextFieldDisabled = newValue }
    }
    var isCostTextFieldDisabled: Bool {
        get { delegate?.isCostTextFieldDisabled ?? true }
        set { delegate?.isCostTextFieldDisabled = newValue }
    }
    var isTimeTextFieldDisabled: Bool {
        get { delegate?.isTimeTextFieldDisabled ?? true }
        set { delegate?.isTimeTextFieldDisabled = newValue }
    }
    
    weak var delegate: RecipeBaseInfoViewModelDelegate?
}

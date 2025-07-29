//
//  RecipeBaseInfoEditor.swift
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

protocol IngredientsInfoViewModelDelegate: AnyObject {
    var servingsText: String { get set }
    var ingredients: [Ingredient] { get set }
    var sources: [Ingredient] { get set }
}

@Observable @MainActor
final class IngredientsInfoViewModel {
    var servingsText: String {
        get { delegate?.servingsText ?? "" }
        set { delegate?.servingsText = newValue }
    }
    var ingredients: [Ingredient] {
        get { delegate?.ingredients ?? [] }
        set { delegate?.ingredients = newValue }
    }
    var sources: [Ingredient] {
        get { delegate?.sources ?? [] }
        set { delegate?.sources = newValue }
    }
    
    weak var delegate: IngredientsInfoViewModelDelegate?
    
    func onAddIngredient() {
        ingredients.append(.init(name: "", units: .init()))
    }
    
    func onRemoveIngredient(with id: UUID) {
        ingredients.removeAll { $0.id == id }
    }
    
    func onMoveIngredientUp(with id: UUID) {
        guard let from = ingredients.firstIndex(where: { $0.id == id }) else { return }
        let to = from - 1
        ingredients.move(fromOffsets: IndexSet(integer: from), toOffset: to)
    }
    
    func onMoveIngredientDown(with id: UUID) {
        guard let from = ingredients.firstIndex(where: { $0.id == id }) else { return }
        let to = from + 2
        ingredients.move(fromOffsets: IndexSet(integer: from), toOffset: to)
    }
    
    func onAddSource() {
        sources.append(.init(name: "", units: .init()))
    }
    
    func onRemoveSource(with id: UUID) {
        sources.removeAll { $0.id == id }
    }
    
    func onMoveSourceUp(with id: UUID) {
        guard let from = sources.firstIndex(where: { $0.id == id }) else { return }
        let to = from - 1
        sources.move(fromOffsets: IndexSet(integer: from), toOffset: to)
    }
    
    func onMoveSourceDown(with id: UUID) {
        guard let from = sources.firstIndex(where: { $0.id == id }) else { return }
        let to = from + 2
        sources.move(fromOffsets: IndexSet(integer: from), toOffset: to)
    }
}

protocol DetailedStepsInfoViewModelDelegate: AnyObject {
    var detailedSteps: [CookingStep] { get set }
}

@Observable @MainActor
final class DetailedStepsInfoViewModel {
    var detailedSteps: [CookingStep] {
        get { delegate?.detailedSteps ?? [] }
        set { delegate?.detailedSteps = newValue }
    }
    
    weak var delegate: DetailedStepsInfoViewModelDelegate?
    
    func onAddStep() {
        detailedSteps.append(.init(title: "Step \(detailedSteps.count + 1)", detailedProcesses: []))
    }
    
    func onRemoveStep(with id: UUID) {
        detailedSteps.removeAll(where: { $0.id == id })
    }
    
    func onAddDetailedProcess(stepID: UUID) {
        guard let index = detailedSteps.firstIndex(where: { $0.id == stepID }) else { return }
        detailedSteps[index].detailedProcesses.append(.init(description: ""))
    }
    
    func onRemoveDetailedProcess(stepID: UUID, processID: UUID) {
        guard let stepIndex = detailedSteps.firstIndex(where: { $0.id == stepID }),
              let processIndex = detailedSteps[stepIndex].detailedProcesses.firstIndex(where: { $0.id == processID })
        else { return }
        detailedSteps[stepIndex].detailedProcesses.remove(at: processIndex)
    }
    
    func onMoveDetailedProcessUp(stepID: UUID, processID: UUID) {
        guard let stepIndex = detailedSteps.firstIndex(where: { $0.id == stepID }),
              let processIndex = detailedSteps[stepIndex].detailedProcesses.firstIndex(where: { $0.id == processID })
        else { return }
        detailedSteps[stepIndex].detailedProcesses.move(fromOffsets: IndexSet(integer: processIndex), toOffset: processIndex - 1)
    }
    
    func onMoveDetailedProcessDown(stepID: UUID, processID: UUID) {
        guard let stepIndex = detailedSteps.firstIndex(where: { $0.id == stepID }),
              let processIndex = detailedSteps[stepIndex].detailedProcesses.firstIndex(where: { $0.id == processID })
        else { return }
        detailedSteps[stepIndex].detailedProcesses.move(fromOffsets: IndexSet(integer: processIndex), toOffset: processIndex + 2)
    }
}

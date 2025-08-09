//
//  IngredientsInfoViewModel.swift
//  RecipeForT
//
//  Created by Swain Yun on 7/29/25.
//

import Foundation

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

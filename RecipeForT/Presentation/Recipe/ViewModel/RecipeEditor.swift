//
//  RecipeEditor.swift
//  RecipeForT
//
//  Created by Swain Yun on 7/1/25.
//

import Foundation

@Observable @MainActor
final class RecipeEditor {
    var titleText: String
    var servingsText: String {
        didSet { synchronize(servingsText) }
    }
    var costText: String
    var timeText: String
    var notesText: String
    var ingredients: [Ingredient]
    
    var servings: Decimal
    
    var isServingsTextFieldDisabled: Bool = false {
        didSet {
            guard isServingsTextFieldDisabled else { return servingsText.removeAll() }
            servingsText = "Not sure"
        }
    }
    var isCostTextFieldDisabled: Bool = false {
        didSet {
            guard isCostTextFieldDisabled else { return costText.removeAll() }
            costText = "Not sure"
        }
    }
    var isTimeTextFieldDisabled: Bool = false {
        didSet {
            guard isTimeTextFieldDisabled else { return timeText.removeAll() }
            timeText = "Not sure"
        }
    }
    
    
    init(recipe: Recipe? = nil) {
        let source = recipe ?? .sample
        titleText = source.name
        servingsText = source.servingsCount == 0 ? "4" : source.servingsCount.description
        costText = source.cost == 0 ? "" : source.cost.description
        timeText = source.cookingTime == 0 ? "" : source.cookingTime.description
        notesText = source.description
        ingredients = source.ingredients
        servings = source.servingsCount
    }
    
    private func synchronize(_ servingsText: String) {
        guard let decimal = Decimal(string: servingsText),
              servings != decimal
        else { return }
        servings = decimal
    }
}

// MARK: - Interfaces
extension RecipeEditor {
    func removeIngredient(with id: UUID) {
        ingredients.removeAll { $0.id == id }
    }
    
    func moveIngredientUp(with id: UUID) {
        guard let originIndex = ingredients.firstIndex(where: { $0.id == id }),
              originIndex > 0
        else { return }
        ingredients.move(fromOffsets: IndexSet(integer: originIndex), toOffset: originIndex - 1)
    }
    
    func moveIngredientDown(with id: UUID) {
        guard let originIndex = ingredients.firstIndex(where: { $0.id == id }),
              originIndex < ingredients.count - 1
        else { return }
        ingredients.move(fromOffsets: IndexSet(integer: originIndex), toOffset: originIndex + 2)
    }
    
    func addIngredient() {
        ingredients.append(Ingredient(name: "", units: .init()))
    }
    
    func increaseServingsCount() {
        let maxServings: Decimal = 100
        guard servings < maxServings else { return }
        servings += 0.5
        servingsText = servings.description
    }
    
    func decreaseServingsCount() {
        let minServings: Decimal = 0
        guard servings > minServings else { return }
        servings -= 0.5
        servingsText = servings.description
    }
}

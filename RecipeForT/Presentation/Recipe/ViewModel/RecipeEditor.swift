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
    func moveIngredient(from source: IndexSet, to destination: Int) {
        ingredients.move(fromOffsets: source, toOffset: destination)
    }
    
    func addIngredient() {
        ingredients.append(Ingredient(name: "", units: .init()))
    }
    
    func removeIngredient(_ ingredient: Ingredient) {
        guard let index = ingredients.firstIndex(where: { $0.id == ingredient.id }) else { return }
        ingredients.remove(at: index)
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

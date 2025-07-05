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
        didSet { servings = UInt8(servingsText) ?? .zero }
    }
    var costText: String
    var timeText: String
    var notesText: String
    var ingredients: [Ingredient]
    
    var servings: UInt8
    
    init(recipe: Recipe? = nil) {
        let source = recipe ?? .sample
        titleText = source.name
        servingsText = source.servingsCount == 0 ? "4" : String(source.servingsCount)
        costText = source.cost == 0 ? "" : source.cost.description
        timeText = source.cookingTime == 0 ? "" : String(source.cookingTime)
        notesText = source.description
        ingredients = source.ingredients
        servings = source.servingsCount
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
        guard servings < UInt8.max else { return }
        servings += 1
        servingsText = String(servings)
    }
    
    func decreaseServingsCount() {
        guard servings > UInt8.min else { return }
        servings -= 1
        servingsText = String(servings)
    }
}

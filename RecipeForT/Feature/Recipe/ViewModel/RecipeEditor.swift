//
//  RecipeEditor.swift
//  RecipeForT
//
//  Created by Swain Yun on 7/1/25.
//

import Foundation

@Observable @MainActor
final class RecipeEditor {
    var title: String
    var servings: String
    var cost: String
    var time: String
    var notes: String
    var ingredients: [Ingredient]
    
    init(recipe: Recipe? = nil) {
        let source = recipe ?? .sample
        title = source.name
        servings = source.servingsCount == 0 ? "" : String(source.servingsCount)
        cost = source.cost == 0 ? "" : source.cost.description
        time = source.cookingTime == 0 ? "" : String(source.cookingTime)
        notes = source.description
        ingredients = source.ingredients
    }
}

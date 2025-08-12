//
//  EditRecipeState.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/12/25.
//

import Foundation

@Observable @MainActor
final class EditRecipeState {
    var title = String()
    var image: Data?
    var servings = String()
    var cost = String()
    var time = String()
    var notes = String()
    var isServingsDisabled = false
    var isCostDisabled = false
    var isTimeDisabled = false
    var ingredients = [Ingredient]()
    var sources = [Ingredient]()
    var steps = [CookingStep]()
    var isMustReadSheetPresented: Bool = false
    private var tasks: [String: Task<Void, Never>] = [:]
    
    init(recipe: Recipe?) {
        let recipe = recipe ?? .sample
        title = recipe.name
        servings = recipe.servingsCount == 0 ? "4" : recipe.servingsCount?.description ?? ""
        cost = recipe.cost == 0 ? "" : recipe.cost?.description ?? ""
        time = recipe.cookingTime == 0 ? "" : recipe.cookingTime?.description ?? ""
        notes = recipe.description
        ingredients = recipe.ingredients
        sources = recipe.sources
        steps = recipe.detailedSteps
    }
}

// MARK: - Interfaces
extension EditRecipeState {
    func cancelTask(for key: String) {
        tasks[key]?.cancel()
    }
    
    func storeTask(for key: String, task: Task<Void, Never>) {
        tasks[key] = task
    }
}

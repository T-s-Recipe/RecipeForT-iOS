//
//  EditRecipeState.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/12/25.
//

import Foundation

@Observable @MainActor
final class EditRecipeState: ViewState {
    enum MissingField: Hashable {
        case image, title, ingredients, steps
        
        var scrollTargetID: String {
            switch self {
            case .image, .title: "baseInfoSection"
            case .ingredients: "ingredientsSection"
            case .steps: "stepsSection"
            }
        }
    }
    
    var title = String()
    var image: ImageItem?
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
    var floaterItem: FloaterItem?
    var isLoading: Bool = false
    var missingField: MissingField?
    var tasks: [String: Task<Void, Never>] = [:]
    
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
    
}

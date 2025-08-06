//
//  RecipeEditor.swift
//  RecipeForT
//
//  Created by Swain Yun on 7/1/25.
//

import Foundation
import Swinject

@Observable @MainActor
final class RecipeEditor {
    var titleText: String
    var servingsText: String
    var costText: String
    var timeText: String
    var notesText: String
    var ingredients: [Ingredient]
    var sources: [Ingredient]
    var detailedSteps: [CookingStep]
    
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
    
    private let maxServings: Decimal = 100
    let minServings: Decimal = 0
    
//    private let recipeUploadUseCase: RecipeUploadUseCaseProtocol
    
    init(recipe: Recipe? = nil, resolver: Resolver) {
        let recipe = recipe ?? .sample
        titleText = recipe.name
        servingsText = recipe.servingsCount == 0 ? "4" : recipe.servingsCount?.description ?? ""
        costText = recipe.cost == 0 ? "" : recipe.cost?.description ?? ""
        timeText = recipe.cookingTime == 0 ? "" : recipe.cookingTime?.description ?? ""
        notesText = recipe.description
        ingredients = recipe.ingredients
        sources = recipe.sources
        detailedSteps = recipe.detailedSteps
//        self.recipeUploadUseCase = resolver.resolve(RecipeUploadUseCaseProtocol.self)!
    }
}

// MARK: - Interfaces
extension RecipeEditor {
    
}

// MARK: - RecipeBaseInfoViewModelDelegate Conformation
extension RecipeEditor: @preconcurrency RecipeBaseInfoViewModelDelegate {
    
}

// MARK: - IngredientsInfoViewModelDelegate Conformation
extension RecipeEditor: @preconcurrency IngredientsInfoViewModelDelegate {
    
}

// MARK: - DetailedStepsInfoViewModelDelegate Conformation
extension RecipeEditor: @preconcurrency DetailedStepsInfoViewModelDelegate {
    
}

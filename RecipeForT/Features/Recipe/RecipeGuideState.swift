//
//  RecipeGuideState.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/12/25.
//

import Foundation

@MainActor @Observable
final class RecipeGuideState: ViewState {
    private(set) var servings: Decimal?
    private(set) var ingredients: [Ingredient]
    private(set) var sources: [Ingredient]
    private(set) var detailedSteps: [CookingStep]
    
    private let maxServing: Decimal = 100
    private let minServing: Decimal = 1
    private let originalServings: Decimal
    private let originalIngredients: [Ingredient]
    private let originalSources: [Ingredient]
    
    var tasks: [String : Task<Void, Never>] = [:]
    
    init(recipe: Recipe) {
        self.servings = recipe.servingsCount
        self.ingredients = recipe.ingredients
        self.sources = recipe.sources
        self.detailedSteps = recipe.detailedSteps
        self.originalServings = recipe.servingsCount ?? 1
        self.originalIngredients = recipe.ingredients
        self.originalSources = recipe.sources
    }
    
    private func adjustQuantities() {
        guard let servings = servings, servings >= minServing, servings <= maxServing else { return }
        let ratio = servings / originalServings
        
        ingredients.enumerated().forEach { index, _ in
            for unit in MeasurementUnit.allCases {
                if let originalQuantity = originalIngredients[index].units[unit] {
                    ingredients[index].units[unit] = (originalQuantity * ratio).rounded(to: 2)
                }
            }
        }
        
        sources.enumerated().forEach { index, _ in
            for unit in MeasurementUnit.allCases {
                if let originalQuantity = originalSources[index].units[unit] {
                    sources[index].units[unit] = (originalQuantity * ratio).rounded(to: 2)
                }
            }
        }
    }
}

// MARK: - Interfaces
extension RecipeGuideState {
    func increaseServing() {
        guard let currentServings = servings, currentServings < maxServing else { return }
        servings = (currentServings + 0.5).rounded(to: 1)
        adjustQuantities()
    }
    
    func decreaseServing() {
        guard let currentServings = servings, currentServings > minServing else { return }
        servings = (currentServings - 0.5).rounded(to: 1)
        adjustQuantities()
    }
}

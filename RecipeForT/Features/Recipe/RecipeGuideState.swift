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
    private(set) var ingredients: [Ingredient] = []
    private(set) var sources: [Ingredient] = []
    private(set) var detailedSteps: [CookingStep] = []
    var floaterItem: FloaterItem?
    
    private let maxServing: Decimal = 100
    private let minServing: Decimal = 1
    private var originalServings: Decimal?
    private var originalIngredients: [Ingredient]?
    private var originalSources: [Ingredient]?
    
    var tasks: [String : Task<Void, Never>] = [:]
    
    private func adjustQuantities() {
        guard let originalServings = originalServings, let originalIngredients = originalIngredients, let originalSources = originalSources  else { return }
        
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
    func synchronize(_ recipe: Recipe) {
        servings = recipe.servingsCount
        ingredients = recipe.ingredients
        sources = recipe.sources
        detailedSteps = recipe.detailedSteps
        originalServings = recipe.servingsCount ?? 1
        originalIngredients = recipe.ingredients
        originalSources = recipe.sources
    }
    
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

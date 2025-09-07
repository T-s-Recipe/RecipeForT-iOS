//
//  RecipeClient.swift
//  RecipeForT
//
//  Created by Swain Yun on 9/2/25.
//

import Foundation

struct RecipeClient {
    var create: @Sendable (
        _ userID: String,
        _ title: String,
        _ image: ImageItem?,
        _ servings: Decimal?,
        _ cost: Decimal?,
        _ cookingTime: Decimal?,
        _ notes: String,
        _ basicIngredients: [Ingredient],
        _ sources: [Ingredient],
        _ detailedSteps: [CookingStep]
    ) async throws -> Recipe
    
    var readPage: @Sendable (_ pageID: String?, _ limit: Int32) async throws -> RecipePage
    
    var readRecipe: @Sendable (_ recipeID: String) async throws -> Recipe
    
    var uploadImage: @Sendable (_ item: ImageItem?) async throws -> URL?
}

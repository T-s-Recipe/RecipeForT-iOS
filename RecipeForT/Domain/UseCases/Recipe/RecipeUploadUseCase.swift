//
//  RecipeUploadUseCase.swift
//  RecipeForT
//
//  Created by Swain Yun on 7/21/25.
//

import Foundation

protocol RecipeUploadUseCaseProtocol {
    func execute(image: Data, title: String, servings: UInt?, cost: Double?, duration: Double?, description: String?, ingredients: [Ingredient], steps: [CookingStep]) async throws
}

final class RecipeUploadUseCase {
    private let recipeRepository: RecipeRepositoryProtocol
    
    init(recipeRepository: RecipeRepositoryProtocol) {
        self.recipeRepository = recipeRepository
    }
}

// MARK: - RecipeUploadUseCaseProtocol Conformation
extension RecipeUploadUseCase: RecipeUploadUseCaseProtocol {
    func execute(image: Data, title: String, servings: UInt?, cost: Double?, duration: Double?, description: String?, ingredients: [Ingredient], steps: [CookingStep]) async throws {
        
    }
}

//
//  RecipePagenationUseCase.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/6/25.
//

import Foundation

final class RecipePagenationUseCase {
    private let recipeRepository: RecipeRepositoryProtocol
    
    init(recipeRepository: RecipeRepositoryProtocol) {
        self.recipeRepository = recipeRepository
    }
}

// MARK: - Interfaces
extension RecipePagenationUseCase {
    func fetchRecipes(pageID: String?, limit: Int32 = 16) async throws -> [Recipe] {
        
    }
}

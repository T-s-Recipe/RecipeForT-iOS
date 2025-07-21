//
//  RecipeSearchUseCase.swift
//  RecipeForT
//
//  Created by Swain Yun on 7/21/25.
//

import Foundation

protocol RecipeSearchUseCaseProtocol {
    func execute(by keyword: String) async throws -> [Recipe]
}

final class RecipeSearchUseCase {
    private let recipeRepository: RecipeRepositoryProtocol
    
    init(recipeRepository: RecipeRepositoryProtocol) {
        self.recipeRepository = recipeRepository
    }
}

// MARK: - RecipeSearchUseCaseProtocol Conformation
extension RecipeSearchUseCase: RecipeSearchUseCaseProtocol {
    func execute(by keyword: String) async throws -> [Recipe] {
        // TODO: WIP
    }
}

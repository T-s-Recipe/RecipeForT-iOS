//
//  RecipeRepository.swift
//  RecipeForT
//
//  Created by Swain Yun on 7/5/25.
//

import Foundation

final class RecipeRepository {
    private var recipes: [Recipe] = []
}

// MARK: - RecipeRepositoryProtocol Conformation
extension RecipeRepository: RecipeRepositoryProtocol {
    func create(_ recipe: Recipe) async throws {
        
    }
    
    func read(isRefreshNeeded: Bool) async throws -> [Recipe] {
        []
    }
    
    func update(_ recipe: Recipe) async throws {
        
    }
    
    func delete(_ id: UInt64) async throws {
        
    }
}

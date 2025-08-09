//
//  RecipeLibrary.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/9/25.
//

import Foundation
import Swinject

@Observable @MainActor
final class RecipeLibrary {
    private(set) var recipes: [Recipe] = []
    private(set) var isLoading: Bool = false
    private(set) var floater: FloaterItem?
    private var nextPageID: String?
    private let fetchLimit: Int32 = 16
    
    private let recipeRepository: RecipeRepositoryProtocol
    
    init(resolver: Resolver) {
        self.recipeRepository = resolver.resolve(RecipeRepositoryProtocol.self)!
    }
    
    private func readRecipes() async {
        guard isLoading == false else { return }
        
        isLoading = true
        
        do {
            let page = try await recipeRepository.read(pageID: nextPageID, limit: fetchLimit)
            recipes.append(contentsOf: page.recipes)
            nextPageID = page.nextPageID
        } catch {
            floater = .init(role: .warning, message: "Failed to load recipes.")
        }
        
        isLoading = false
    }
}

// MARK: - Interfaces
extension RecipeLibrary {
    func loadRecipesIfNeeded(_ id: String) {
        guard recipes.isEmpty == false, let targetRecipe = recipes.last, targetRecipe.id == id else { return }
        loadRecipes()
    }
    
    func loadRecipes() {
        Task {
            await readRecipes()
        }
    }
    
    func refresh() {
        recipes.removeAll()
        nextPageID = nil
        loadRecipes()
    }
}

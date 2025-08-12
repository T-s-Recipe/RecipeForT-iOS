//
//  RecipeRepositoryEnvironmentKey.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/12/25.
//

import SwiftUI

struct RecipeRepositoryEnvironmentKey: EnvironmentKey {
    private static let tokenStorage = TokenStorage()
    
    static let defaultValue: RecipeRepositoryProtocol = RecipeRepository(networkService: NetworkService(tokenStorage: tokenStorage))
}

extension EnvironmentValues {
    var recipeRepository: RecipeRepositoryProtocol {
        get { self[RecipeRepositoryEnvironmentKey.self] }
        set { self[RecipeRepositoryEnvironmentKey.self] = newValue }
    }
}

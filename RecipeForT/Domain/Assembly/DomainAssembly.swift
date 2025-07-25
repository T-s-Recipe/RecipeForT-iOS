//
//  DomainAssembly.swift
//  RecipeForT
//
//  Created by Swain Yun on 7/25/25.
//

import Foundation
import Swinject

struct DomainAssembly: Assembly {
    func assemble(container: Container) {
        container.register(RecipeUploadUseCaseProtocol.self) { resolver in
            guard let recipeRepository = resolver.resolve(RecipeRepositoryProtocol.self) else {
                let recipeRepository = RecipeRepository()
                container.register(RecipeRepositoryProtocol.self) { _ in
                    recipeRepository
                }
                return RecipeUploadUseCase(recipeRepository: recipeRepository)
            }
            return RecipeUploadUseCase(recipeRepository: recipeRepository)
        }
        
        container.register(RecipeSearchUseCaseProtocol.self) { resolver in
            guard let recipeRepository = resolver.resolve(RecipeRepositoryProtocol.self) else {
                let recipeRepository = RecipeRepository()
                container.register(RecipeRepositoryProtocol.self) { _ in
                    recipeRepository
                }
                return RecipeSearchUseCase(recipeRepository: recipeRepository)
            }
            return RecipeSearchUseCase(recipeRepository: recipeRepository)
        }
        
        container.register(LoginUseCaseProtocol.self) { resolver in
            guard let userRepository = resolver.resolve(UserRepositoryProtocol.self) else {
                let userRepository = UserRepository()
                container.register(UserRepositoryProtocol.self) { _ in
                    userRepository
                }
                return LoginUseCase(userRepository: userRepository)
            }
            return LoginUseCase(userRepository: userRepository)
        }
    }
}

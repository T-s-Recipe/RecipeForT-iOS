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
            guard let memberRepository = resolver.resolve(MemberRepositoryProtocol.self) else {
                let memberRepository = MemberRepository()
                container.register(MemberRepositoryProtocol.self) { _ in
                    memberRepository
                }
                return LoginUseCase(memberRepository: memberRepository)
            }
            return LoginUseCase(memberRepository: memberRepository)
        }
    }
}

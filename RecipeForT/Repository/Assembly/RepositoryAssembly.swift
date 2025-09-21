//
//  RepositoryAssembly.swift
//  RecipeForT
//
//  Created by Swain Yun on 7/25/25.
//

import Foundation
import Swinject

struct RepositoryAssembly: Assembly {
    func assemble(container: Container) {
        container.register(RecipeRepositoryProtocol.self) { resolver in
            RecipeRepository(networkService: resolver.resolve(NetworkServiceProtocol.self)!)
        }
        .inObjectScope(.container)
        
        container.register(MemberRepositoryProtocol.self) { resolver in
            MemberRepository(
                networkService: resolver.resolve(NetworkServiceProtocol.self)!,
                tokenStorage: resolver.resolve(TokenStorageProtocol.self)!
            )
        }
        .inObjectScope(.container)
        
        container.register(SupportRepositoryProtocol.self) { resolver in
            SupportRepository(networkService: resolver.resolve(NetworkServiceProtocol.self)!)
        }
        .inObjectScope(.container)
    }
}

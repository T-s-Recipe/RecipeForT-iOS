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
            RecipeRepository()
        }
        .inObjectScope(.container)
        
        container.register(MemberRepositoryProtocol.self) { resolver in
            guard let networkService = resolver.resolve(NetworkServiceProtocol.self),
                  let tokenStorage = resolver.resolve(TokenStorageProtocol.self)
            else {
                let tokenStorage = TokenStorage()
                let networkService = NetworkService(tokenStorage: tokenStorage)
                container.register(TokenStorageProtocol.self) { _ in tokenStorage }
                container.register(NetworkServiceProtocol.self) { _ in networkService }
                return MemberRepository(networkService: networkService, tokenStorage: tokenStorage)
            }
            return MemberRepository(networkService: networkService, tokenStorage: tokenStorage)
        }
        .inObjectScope(.container)
    }
}

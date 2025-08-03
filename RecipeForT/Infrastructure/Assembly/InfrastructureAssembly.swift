//
//  InfrastructureAssembly.swift
//  RecipeForT
//
//  Created by Swain Yun on 7/25/25.
//

import Foundation
import Swinject

struct InfrastructureAssembly: Assembly {
    func assemble(container: Container) {
        container.register(NetworkServiceProtocol.self) { resolver in
            guard let tokenStorage = resolver.resolve(TokenStorageProtocol.self) else {
                let tokenStorage = TokenStorage()
                container.register(TokenStorageProtocol.self) { _ in
                    tokenStorage
                }
                return NetworkService(tokenStorage: tokenStorage)
            }
            return NetworkService(tokenStorage: tokenStorage)
        }
        .inObjectScope(.container)
    }
}

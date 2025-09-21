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
        container.register(TokenStorageProtocol.self) { _ in
            TokenStorage()
        }
        .inObjectScope(.container)
        
        container.register(NetworkServiceProtocol.self) { resolver in
            NetworkService(tokenStorage: resolver.resolve(TokenStorageProtocol.self)!)
        }
        .inObjectScope(.container)
    }
}

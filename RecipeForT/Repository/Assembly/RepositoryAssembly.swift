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
    }
}

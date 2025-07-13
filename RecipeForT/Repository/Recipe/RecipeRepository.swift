//
//  RecipeRepository.swift
//  RecipeForT
//
//  Created by Swain Yun on 7/5/25.
//

import Foundation

protocol RecipeRepositoryProtocol {
    func create(_ recipe: Recipe) async throws
    func read() async throws -> [Recipe]
    func update(_ recipe: Recipe) async throws
    func delete(_ id: UInt64) async throws
}

//
//  RecipeRepository.swift
//  RecipeForT
//
//  Created by Swain Yun on 7/5/25.
//

import Foundation

protocol RecipeRepositoryProtocol {
    func create(
        userID: String,
        title: String,
        image: Data?,
        servings: Decimal?,
        cost: Decimal?,
        cookingTime: Decimal?,
        notes: String,
        basicIngredients: [Ingredient],
        sources: [Ingredient],
        detailedSteps: [CookingStep]
    ) async throws -> Recipe
    func read(pageID: String?, limit: Int32) async throws -> [Recipe]
    func update(_ recipe: Recipe) async throws
    func delete(_ id: UInt64) async throws
}

enum RecipeRepositoryError: Error {
    case encodingFailed
    case decodingFailed
    case networkError(Error)
}

final class RecipeRepository {
    private var recipes: [Recipe] = []
    
    private let networkService: NetworkServiceProtocol
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    init(
        networkService: NetworkServiceProtocol,
        decoder: JSONDecoder = JSONDecoder(),
        encoder: JSONEncoder = JSONEncoder()
    ) {
        self.networkService = networkService
        self.decoder = decoder
        self.encoder = encoder
    }
}

// MARK: - RecipeRepositoryProtocol Conformation
extension RecipeRepository: RecipeRepositoryProtocol {
    func create(
        userID: String,
        title: String,
        image: Data?,
        servings: Decimal?,
        cost: Decimal?,
        cookingTime: Decimal?,
        notes: String,
        basicIngredients: [Ingredient],
        sources: [Ingredient],
        detailedSteps: [CookingStep]
    ) async throws -> Recipe {
        let requestDTO = CreateRecipeRequestDTO(
            authorID: userID,
            title: title,
            servings: servings,
            cost: cost,
            cookingTime: cookingTime,
            notes: notes,
            basicIngredients: basicIngredients,
            sources: sources,
            detailedSteps: detailedSteps
        )
        
        do {
            let dtoData = try encoder.encode(requestDTO)
            let endpoint = Endpoint.uploadRecipe(dtoData: dtoData, image: image)
            let response = try await networkService.request(endpoint)
//            let responseDTO = try decoder.decode
        } catch is EncodingError {
            throw RecipeRepositoryError.encodingFailed
        } catch is DecodingError {
            throw RecipeRepositoryError.decodingFailed
        } catch let error as NetworkServiceError {
            throw RecipeRepositoryError.networkError(error)
        }
    }
    
    func read(pageID: String?, limit: Int32) async throws -> [Recipe] {
        []
    }
    
    func update(_ recipe: Recipe) async throws {
        
    }
    
    func delete(_ id: UInt64) async throws {
        
    }
}

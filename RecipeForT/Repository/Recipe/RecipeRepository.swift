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
        image: ImageItem?,
        servings: Decimal?,
        cost: Decimal?,
        cookingTime: Decimal?,
        notes: String,
        basicIngredients: [Ingredient],
        sources: [Ingredient],
        detailedSteps: [CookingStep]
    ) async throws -> Recipe
    func read(pageID: String?, limit: Int32) async throws -> RecipePage
    func update(_ recipe: Recipe) async throws
    func delete(_ id: UInt64) async throws
    
    func uploadRecipeImage(_ item: ImageItem?) async throws -> URL?
}

enum RecipeRepositoryError: Error {
    enum Reason {
        case emptyImage
    }
    
    case notSupported(Reason)
    case encodingFailed
    case decodingFailed
    case networkError(NetworkServiceError)
}

final class RecipeRepository {
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
        image: ImageItem?,
        servings: Decimal?,
        cost: Decimal?,
        cookingTime: Decimal?,
        notes: String,
        basicIngredients: [Ingredient],
        sources: [Ingredient],
        detailedSteps: [CookingStep]
    ) async throws -> Recipe {
        let imageURL = try await uploadRecipeImage(image)
        
        let requestDTO = CreateRecipeRequestDTO(
            authorID: userID,
            title: title,
            imageURL: imageURL,
            servings: servings,
            cost: cost,
            cookingTime: cookingTime,
            notes: notes,
            basicIngredients: basicIngredients,
            sources: sources,
            detailedSteps: detailedSteps
        )
        
        let endpoint = Endpoint.uploadRecipe(requestDTO)
        
        do {
            let response = try await networkService.request(endpoint)
            let responseDTO = try decoder.decode(CreateRecipeResponseDTO.self, from: response.data)
            let recipe = responseDTO.toEntity()
            return recipe
        } catch is EncodingError {
            throw RecipeRepositoryError.encodingFailed
        } catch is DecodingError {
            throw RecipeRepositoryError.decodingFailed
        } catch let error as NetworkServiceError {
            throw RecipeRepositoryError.networkError(error)
        }
    }
    
    func read(pageID: String?, limit: Int32) async throws -> RecipePage {
        let endpoint = Endpoint.fetchRecipeList(nextPageID: pageID, limit: limit)
        
        do {
            let response = try await networkService.request(endpoint)
            let responseDTO = try decoder.decode(RecipeListResponseDTO.self, from: response.data)
            let page = responseDTO.toEntity()
            return page
        } catch is DecodingError {
            throw RecipeRepositoryError.decodingFailed
        } catch let error as NetworkServiceError {
            throw RecipeRepositoryError.networkError(error)
        }
    }
    
    func update(_ recipe: Recipe) async throws {
        
    }
    
    func delete(_ id: UInt64) async throws {
        
    }
    
    func uploadRecipeImage(_ item: ImageItem?) async throws -> URL? {
        guard let item else { throw RecipeRepositoryError.notSupported(.emptyImage) }
        let endpoint = Endpoint.uploadRecipeImage(item)
        
        do {
            let response = try await networkService.request(endpoint)
            let urlString = try response.mapString()
            return URL(string: urlString)
        } catch let error as NetworkServiceError {
            throw RecipeRepositoryError.networkError(error)
        } catch {
            throw RecipeRepositoryError.decodingFailed
        }
    }
}

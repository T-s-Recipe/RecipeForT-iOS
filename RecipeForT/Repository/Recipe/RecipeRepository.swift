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
    func read(recipeID: String) async throws -> Recipe
    func update(_ recipe: Recipe) async throws
    func delete(_ id: UInt64) async throws
    
    func uploadRecipeImage(_ item: ImageItem?) async throws -> URL
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
    
    func read(recipeID: String) async throws -> Recipe {
        let endpoint = Endpoint.fetchRecipeDetail(recipeID: recipeID)
        
        do {
            let response = try await networkService.request(endpoint)
            let responseDTO = try decoder.decode(RecipeResponseDTO.self, from: response.data)
            return responseDTO.toEntity()
        } catch let error as NetworkServiceError {
            throw RecipeRepositoryError.networkError(error)
        } catch is DecodingError {
            throw RecipeRepositoryError.decodingFailed
        }
    }
    
    func update(_ recipe: Recipe) async throws {
        
    }
    
    func delete(_ id: UInt64) async throws {
        
    }
    
    func uploadRecipeImage(_ item: ImageItem?) async throws -> URL {
        guard let item else { throw RecipeRepositoryError.notSupported(.emptyImage) }
        let requestDTO = ImageUploadRequestDTO(fileName: item.filename, mimeType: item.mimeType)
        let endpoint = Endpoint.fetchImageholderLink(requestDTO)
        
        let uploadInfo: ImageUploadResponseDTO
        do {
            let response = try await networkService.request(endpoint)
            uploadInfo = try decoder.decode(ImageUploadResponseDTO.self, from: response.data)
        } catch let error as NetworkServiceError {
            throw RecipeRepositoryError.networkError(error)
        } catch {
            throw RecipeRepositoryError.decodingFailed
        }
        
        try await uploadToS3(url: uploadInfo.uploadURL, imageData: item.data, headers: uploadInfo.uploadHeaders)
        return uploadInfo.imageURL
    }
    
    private func uploadToS3(url: URL, imageData: Data, headers: ImageUploadResponseHeadersDTO) async throws {
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue(headers.contentType, forHTTPHeaderField: "Content-Type")
        request.setValue(headers.host, forHTTPHeaderField: "Host")
        let (_, response) = try await URLSession.shared.upload(for: request, from: imageData)
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode)
        else {
            print("[NetworkService] - Error: S3 Upload failed with response \(response)")
            throw RecipeRepositoryError.networkError(.networkFailure)
        }
    }
}

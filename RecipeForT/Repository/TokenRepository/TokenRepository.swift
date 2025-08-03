//
//  TokenRepository.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/3/25.
//

import Foundation

enum TokenRepositoryError: Error {
    case encodingFailed
    case decodingFailed
    case networkError(Error)
    case storageError(Error)
}

final class TokenRepository {
    private let networkService: NetworkServiceProtocol
    private let tokenStorage: TokenStorageProtocol
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    init(
        networkService: NetworkServiceProtocol,
        tokenStorage: TokenStorageProtocol,
        decoder: JSONDecoder,
        encoder: JSONEncoder
    ) {
        self.networkService = networkService
        self.tokenStorage = tokenStorage
        self.decoder = decoder
        self.encoder = encoder
    }
}

// MARK: - TokenRepositoryProtocol Conformation
extension TokenRepository: TokenRepositoryProtocol {
    func create(authorizationCode: Data, provider: OAuthProvider, name: String?, email: String?) async throws -> AuthenticationState {
        let requestDTO = SignInRequestDTO(
            idToken: authorizationCode.base64EncodedString(),
            providerIdentifier: provider.identifier,
            name: name,
            email: email
        )
        let endpoint = Endpoint.signIn(requestDTO)
        
        do {
            let response = try await networkService.request(endpoint)
            let responseDTO = try decoder.decode(AuthTokenResponseDTO.self, from: response.data)
            let tokens = responseDTO.toEntity()
            return .pendingRegistration(tokens: tokens)
        } catch let error as NetworkServiceError {
            throw TokenRepositoryError.networkError(error)
        } catch {
            throw TokenRepositoryError.decodingFailed
        }
    }
    
    func read() async -> Tokens? {
        do {
            let data = try tokenStorage.fetch()
            let tokens = try decoder.decode(Tokens.self, from: data)
            return tokens
        } catch {
            return nil
        }
    }
    
    func update(tokens: Tokens) async throws {
        
    }
    
    func delete() async throws {
        try tokenStorage.delete()
    }
}

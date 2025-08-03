//
//  MemberRepository.swift
//  RecipeForT
//
//  Created by Swain Yun on 7/13/25.
//

import Foundation
import Moya

enum MemberRepositoryError: Error {
    case invalidResponse
    case memberNotFound
    case authenticationFailed
    case networkError(Error)
}

final class MemberRepository {
    private var authenticationState: AuthenticationState = .loggedOut
    
    private let networkService: NetworkServiceProtocol
    private let tokenStorage: TokenStorageProtocol
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    init(
        networkService: NetworkServiceProtocol,
        tokenStorage: TokenStorageProtocol,
        decoder: JSONDecoder = JSONDecoder(),
        encoder: JSONEncoder = JSONEncoder()
    ) {
        self.networkService = networkService
        self.tokenStorage = tokenStorage
        self.decoder = decoder
        self.encoder = encoder
    }
}

// MARK: - UserRepositoryProtocol Conformation
extension MemberRepository: MemberRepositoryProtocol {
    func create(authorizationCode: Data, provider: OAuthProvider, name: String?, email: String?, nickname: String) async throws -> AuthenticationState {
        let requestDTO = SignUpRequestDTO(
            providerIdentifier: provider.identifier,
            authID: authorizationCode.base64EncodedString(),
            name: name,
            email: email,
            nickname: nickname
        )
        let endpoint = Endpoint.register(requestDTO)
        let response = try await networkService.request(endpoint)
        guard (200..<300).contains(response.statusCode),
              let responseDTO = try? decoder.decode(MemberResponseDTO.self, from: response.data)
        else { throw MemberRepositoryError.invalidResponse }
        
        let member = responseDTO.toEntity()
        authenticationState = .loggedIn(member: member)
        return authenticationState
    }
    
    func read(id: String) async throws -> AuthenticationState {
        let endpoint = Endpoint.fetchMemberInfo(id: id, providerID: nil, authID: nil)
        
        do {
            let response = try await networkService.request(endpoint)
            let responseDTO = try decoder.decode(MemberResponseDTO.self, from: response.data)
            let member = responseDTO.toEntity()
            authenticationState = .loggedIn(member: member)
            return authenticationState
        } catch let error as NetworkServiceError {
            throw MemberRepositoryError.networkError(error)
        } catch {
            throw MemberRepositoryError.invalidResponse
        }
    }
    
    func read(authorizationCode: Data, provider: OAuthProvider) async throws -> AuthenticationState {
        let endpoint = Endpoint.fetchMemberInfo(id: nil, providerID: provider.identifier, authID: authorizationCode.base64EncodedString())
        
        do {
            let response = try await networkService.request(endpoint)
            let responseDTO = try decoder.decode(MemberResponseDTO.self, from: response.data)
            let member = responseDTO.toEntity()
            authenticationState = .loggedIn(member: member)
            return authenticationState
        } catch let error as NetworkServiceError {
            throw MemberRepositoryError.networkError(error)
        } catch {
            throw MemberRepositoryError.invalidResponse
        }
    }
    
    func delete() async throws -> AuthenticationState {
        let data = try tokenStorage.fetch()
        guard let tokens = try? JSONDecoder().decode(Tokens.self, from: data) else { throw MemberRepositoryError.authenticationFailed }
        
        let requestDTO = LogoutRequestDTO(refreshToken: tokens.refreshToken)
        let endpoint = Endpoint.logout(requestDTO)
        _ = try await networkService.request(endpoint)
        
        authenticationState = .loggedOut
        return .loggedOut
    }
}

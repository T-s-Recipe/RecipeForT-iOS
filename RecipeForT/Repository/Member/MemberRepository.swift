//
//  MemberRepository.swift
//  RecipeForT
//
//  Created by Swain Yun on 7/13/25.
//

import Foundation
import Moya

enum MemberRepositoryError: Error {
    case memberNotFound
    case authenticationFailed
    case decodingFailed
    case networkError(Error)
}

final class MemberRepository {
    private(set) var authenticationState: AuthenticationState = .loggedOut
    
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
    func signIn(authCode: Data, provider: OAuthProvider, name: String?, email: String?) async throws -> AuthenticationState {
        let requestDTO = SignInRequestDTO(
            idToken: authCode.base64EncodedString(),
            providerIdentifier: provider.identifier,
            name: name,
            email: email
        )
        let endpoint = Endpoint.signIn(requestDTO)
        
        do {
            let response = try await networkService.request(endpoint)
            let responseDTO = try decoder.decode(AuthTokenResponseDTO.self, from: response.data)
            let tokens = responseDTO.toEntity()
            authenticationState = .pendingRegistration(tokens: tokens)
            return authenticationState
        } catch let error as NetworkServiceError {
            throw MemberRepositoryError.networkError(error)
        } catch is DecodingError {
            throw MemberRepositoryError.decodingFailed
        }
    }
    
    func signUp(authCode: Data, provider: OAuthProvider, name: String?, email: String?, nickname: String) async throws -> AuthenticationState {
        let requestDTO = SignUpRequestDTO(
            providerIdentifier: provider.identifier,
            authID: authCode.base64EncodedString(),
            name: name,
            email: email,
            nickname: nickname
        )
        let endpoint = Endpoint.register(requestDTO)
        
        do {
            let response = try await networkService.request(endpoint)
            let responseDTO = try decoder.decode(MemberResponseDTO.self, from: response.data)
            let member = responseDTO.toEntity()
            authenticationState = .loggedIn(member: member)
            return authenticationState
        } catch let error as NetworkServiceError {
            throw MemberRepositoryError.networkError(error)
        } catch is DecodingError {
            throw MemberRepositoryError.decodingFailed
        }
    }
    
    func fetchMember(id: String) async throws -> AuthenticationState {
        let endpoint = Endpoint.fetchMemberInfo(id: id, providerID: nil, authID: nil)
        
        do {
            let response = try await networkService.request(endpoint)
            let responseDTO = try decoder.decode(MemberResponseDTO.self, from: response.data)
            let member = responseDTO.toEntity()
            authenticationState = .loggedIn(member: member)
            return authenticationState
        } catch let error as NetworkServiceError {
            throw MemberRepositoryError.networkError(error)
        } catch is DecodingError {
            throw MemberRepositoryError.decodingFailed
        }
    }
    
    func fetchMember(authCode: Data, provider: OAuthProvider) async throws -> AuthenticationState {
        let endpoint = Endpoint.fetchMemberInfo(id: nil, providerID: provider.identifier, authID: authCode.base64EncodedString())
        
        do {
            let response = try await networkService.request(endpoint)
            let responseDTO = try decoder.decode(MemberResponseDTO.self, from: response.data)
            let member = responseDTO.toEntity()
            authenticationState = .loggedIn(member: member)
            return authenticationState
        } catch let error as NetworkServiceError {
            throw MemberRepositoryError.networkError(error)
        } catch is DecodingError {
            throw MemberRepositoryError.decodingFailed
        }
    }
    
    func logout() async throws -> AuthenticationState {
        let data = try tokenStorage.fetch()
        guard let tokens = try? JSONDecoder().decode(Tokens.self, from: data) else { throw MemberRepositoryError.authenticationFailed }
        
        let requestDTO = LogoutRequestDTO(refreshToken: tokens.refreshToken)
        let endpoint = Endpoint.logout(requestDTO)
        _ = try await networkService.request(endpoint)
        
        authenticationState = .loggedOut
        return .loggedOut
    }
    
    func fetchRandomNickname() async throws -> String {
        let endpoint = Endpoint.fetchRandomNickname
        
        let response: Response
        do {
            response = try await networkService.request(endpoint)
        } catch {
            throw MemberRepositoryError.networkError(error)
        }
        
        guard let nickname = String(data: response.data, encoding: .utf8) else { throw MemberRepositoryError.decodingFailed }
        return nickname
    }
}

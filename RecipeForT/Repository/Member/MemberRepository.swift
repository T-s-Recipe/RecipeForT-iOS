//
//  MemberRepository.swift
//  RecipeForT
//
//  Created by Swain Yun on 7/13/25.
//

import Foundation
import Moya

protocol MemberRepositoryProtocol {
    func signIn(idToken: String, provider: OAuthProvider) async throws -> SignInAttemptRecord
    func signUp(ci: String, provider: OAuthProvider, nickname: String) async throws -> Member
    func fetchMember() async throws -> Member
    func logout() async
    func fetchRandomNickname() async throws -> String
    func isNicknameDuplicated(nickname: String) async throws -> Bool
}

enum MemberRepositoryError: Error {
    case memberNotFound
    case authenticationFailed
    case decodingFailed
    case encodingFailed
    case networkError(NetworkServiceError)
    case storageError(Error)
}

final class MemberRepository {
    private(set) var authenticationState: AuthenticationState = .loggedOut
    var isLoggedIn: Bool {
        guard case .loggedIn = authenticationState else { return false }
        return true
    }
    
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
    
    private func recieveToken(tokens: Tokens) throws {
        do {
            let data = try encoder.encode(tokens)
            try tokenStorage.store(data)
        } catch is EncodingError {
            throw MemberRepositoryError.encodingFailed
        } catch {
            throw MemberRepositoryError.storageError(error)
        }
    }
}

// MARK: - UserRepositoryProtocol Conformation
extension MemberRepository: MemberRepositoryProtocol {
    func signIn(idToken: String, provider: OAuthProvider) async throws -> SignInAttemptRecord {
        let requestDTO = SignInRequestDTO(idToken: idToken, providerIdentifier: provider.identifier)
        let endpoint = Endpoint.signIn(requestDTO)
        
        do {
            let response = try await networkService.request(endpoint)
            let responseDTO = try decoder.decode(SignInResponseDTO.self, from: response.data)
            
            guard responseDTO.isRegistered,
                  let memberID = responseDTO.authTokenResponse?.memberID,
                  let tokens = responseDTO.authTokenResponse?.toEntity()
            else { return responseDTO.toEntity(idToken: idToken, provider: provider) }
            
            try recieveToken(tokens: tokens)
            UserDefaults.standard.setValue(memberID, forKey: AppStorageKey.userID)
            return responseDTO.toEntity(idToken: idToken, provider: provider)
        } catch let error as NetworkServiceError {
            throw MemberRepositoryError.networkError(error)
        } catch is DecodingError {
            throw MemberRepositoryError.decodingFailed
        }
    }
    
    func signUp(ci: String, provider: OAuthProvider, nickname: String) async throws -> Member {
        let requestDTO = SignUpRequestDTO(providerIdentifier: provider.identifier, ci: ci, nickname: nickname)
        let endpoint = Endpoint.register(requestDTO)
        
        do {
            let response = try await networkService.request(endpoint)
            let responseDTO = try decoder.decode(MemberResponseDTO.self, from: response.data)
            return responseDTO.toEntity()
        } catch let error as NetworkServiceError {
            throw MemberRepositoryError.networkError(error)
        } catch is DecodingError {
            throw MemberRepositoryError.decodingFailed
        }
    }
    
    func fetchMember() async throws -> Member {
        guard let _ = try? tokenStorage.fetch() else { throw MemberRepositoryError.memberNotFound }
        
        let endpoint = Endpoint.fetchMemberInfo
        
        do {
            let response = try await networkService.request(endpoint)
            let responseDTO = try decoder.decode(MemberResponseDTO.self, from: response.data)
            return responseDTO.toEntity()
        } catch let error as NetworkServiceError {
            throw MemberRepositoryError.networkError(error)
        } catch is DecodingError {
            throw MemberRepositoryError.decodingFailed
        }
    }
    
    func logout() async {
        UserDefaults.standard.removeObject(forKey: AppStorageKey.userID)
        
        guard let data = try? tokenStorage.fetch(),
              let tokens = try? decoder.decode(Tokens.self, from: data)
        else { return }
        
        let requestDTO = LogoutRequestDTO(refreshToken: tokens.refreshToken)
        let endpoint = Endpoint.logout(requestDTO)
        _ = try? await networkService.request(endpoint)
        try? tokenStorage.delete()
    }
    
    func fetchRandomNickname() async throws -> String {
        let endpoint = Endpoint.fetchRandomNickname
        
        let response: Response
        do {
            response = try await networkService.request(endpoint)
        } catch let error as NetworkServiceError {
            throw MemberRepositoryError.networkError(error)
        }
        
        guard let nickname = String(data: response.data, encoding: .utf8) else { throw MemberRepositoryError.decodingFailed }
        return nickname
    }
    
    func isNicknameDuplicated(nickname: String) async throws -> Bool {
        let endpoint = Endpoint.checkNicknameDuplication(nickname: nickname)
        
        do {
            let response = try await networkService.request(endpoint)
            let isDuplicated = try response.mapString() == "true" ? true : false
            return isDuplicated
        } catch let error as NetworkServiceError {
            throw MemberRepositoryError.networkError(error)
        } catch {
            throw MemberRepositoryError.decodingFailed
        }
    }
}

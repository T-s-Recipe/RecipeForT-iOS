//
//  MemberRepository.swift
//  RecipeForT
//
//  Created by Swain Yun on 7/13/25.
//

import Foundation
import Moya

protocol MemberRepositoryProtocol {
    var authenticationState: AuthenticationState { get }
    var isLoggedIn: Bool { get }
    
    func signIn(idToken: String, provider: OAuthProvider) async throws -> AuthenticationState
    func signUp(nickname: String) async throws -> AuthenticationState
    func fetchMember() async throws -> AuthenticationState
    func fetchMember(id: String) async throws -> AuthenticationState
    func fetchMember(ci: String, provider: OAuthProvider) async throws -> AuthenticationState
    func logout() async throws -> AuthenticationState
    func fetchRandomNickname() async throws -> String
}

enum MemberRepositoryError: Error {
    case memberNotFound
    case authenticationFailed
    case decodingFailed
    case encodingFailed
    case networkError(Error)
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
        } catch {
            throw MemberRepositoryError.encodingFailed
        }
    }
}

// MARK: - UserRepositoryProtocol Conformation
extension MemberRepository: MemberRepositoryProtocol {
    func signIn(idToken: String, provider: OAuthProvider) async throws -> AuthenticationState {
        let requestDTO = SignInRequestDTO(idToken: idToken, providerIdentifier: provider.identifier)
        let endpoint = Endpoint.signIn(requestDTO)
        
        do {
            let response = try await networkService.request(endpoint)
            let responseDTO = try decoder.decode(SignInResponseDTO.self, from: response.data)
            
            guard responseDTO.isRegistered,
                  let member = responseDTO.member?.toEntity(),
                  let accessToken = responseDTO.accessToken,
                  let refreshToken = responseDTO.refreshToken
            else {
                let record = SignInAttemptRecord(idToken: idToken, provider: provider, ci: responseDTO.ci)
                authenticationState = .pendingRegistration(record: record)
                return authenticationState
            }
            let tokens = Tokens(accessToken: accessToken, refreshToken: refreshToken)
            try recieveToken(tokens: tokens)
            UserDefaults.standard.setValue(member.id, forKey: AppStorageKey.userID)
            return .loggedIn(member: member)
        } catch let error as NetworkServiceError {
            throw MemberRepositoryError.networkError(error)
        } catch is DecodingError {
            throw MemberRepositoryError.decodingFailed
        }
    }
    
    func signUp(nickname: String) async throws -> AuthenticationState {
        guard case .pendingRegistration(let record) = authenticationState else { throw MemberRepositoryError.memberNotFound }
        let requestDTO = SignUpRequestDTO(providerIdentifier: record.provider.identifier, ci: record.ci, nickname: nickname)
        let endpoint = Endpoint.register(requestDTO)
        
        do {
            _ = try await networkService.request(endpoint)
            authenticationState = try await signIn(idToken: record.idToken, provider: record.provider)
            return authenticationState
        } catch let error as NetworkServiceError {
            throw MemberRepositoryError.networkError(error)
        } catch is DecodingError {
            throw MemberRepositoryError.decodingFailed
        }
    }
    
    func fetchMember() async throws -> AuthenticationState {
        guard authenticationState == .loggedOut else { return authenticationState }
        
        guard let userID = UserDefaults.standard.string(forKey: AppStorageKey.userID) else {
            authenticationState = .loggedOut
            return authenticationState
        }
        
        return try await fetchMember(id: userID)
    }
    
    func fetchMember(id: String) async throws -> AuthenticationState {
        guard authenticationState == .loggedOut else { return authenticationState }
        
        let endpoint = Endpoint.fetchMemberInfo(id: id, providerID: nil, ci: nil)
        
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
    
    func fetchMember(ci: String, provider: OAuthProvider) async throws -> AuthenticationState {
        guard authenticationState == .loggedOut else { return authenticationState }
        
        let endpoint = Endpoint.fetchMemberInfo(id: nil, providerID: provider.identifier, ci: ci)
        
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
        UserDefaults.standard.removeObject(forKey: AppStorageKey.userID)
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

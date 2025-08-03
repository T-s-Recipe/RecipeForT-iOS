//
//  LoginUseCase.swift
//  RecipeForT
//
//  Created by Swain Yun on 7/22/25.
//

import Foundation

protocol LoginUseCaseProtocol {
    func execute(authorizationCode: Data, provider: OAuthProvider, email: String?, name: String?) async throws -> AuthenticationState
    func execute(userID: String) async throws -> AuthenticationState
}

final class LoginUseCase {
    private let memberRepository: MemberRepositoryProtocol
    private let tokenRepository: TokenRepositoryProtocol
    
    init(
        memberRepository: MemberRepositoryProtocol,
        tokenRepository: TokenRepositoryProtocol
    ) {
        self.memberRepository = memberRepository
        self.tokenRepository = tokenRepository
    }
}

// MARK: - LoginUseCaseProtocol Conformation
extension LoginUseCase: LoginUseCaseProtocol {
    func execute(authorizationCode: Data, provider: OAuthProvider, email: String?, name: String?) async throws -> AuthenticationState {
        return try await tokenRepository.create(authorizationCode: authorizationCode, provider: provider, name: name, email: email)
    }
    
    func execute(userID: String) async throws -> AuthenticationState {
        return try await memberRepository.read(id: userID)
    }
}

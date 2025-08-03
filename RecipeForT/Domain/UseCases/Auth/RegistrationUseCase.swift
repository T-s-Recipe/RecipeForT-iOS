//
//  RegistrationUseCase.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/2/25.
//

import Foundation

protocol RegistrationUseCaseProtocol {
    func execute(authorizationCode: Data, provider: OAuthProvider, name: String?, email: String?, nickname: String) async throws -> AuthenticationState
}

final class RegistrationUseCase {
    private let memberRepository: MemberRepositoryProtocol
    
    init(memberRepository: MemberRepositoryProtocol) {
        self.memberRepository = memberRepository
    }
}

// MARK: - RegistrationUseCaseProtocol Conformation
extension RegistrationUseCase: RegistrationUseCaseProtocol {
    func execute(authorizationCode: Data, provider: OAuthProvider, name: String?, email: String?, nickname: String) async throws -> AuthenticationState {
        return try await memberRepository.create(authorizationCode: authorizationCode, provider: provider, name: name, email: email, nickname: nickname)
    }
}

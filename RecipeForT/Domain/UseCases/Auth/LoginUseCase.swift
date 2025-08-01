//
//  LoginUseCase.swift
//  RecipeForT
//
//  Created by Swain Yun on 7/22/25.
//

import Foundation

protocol LoginUseCaseProtocol {
    func login(authorizationCode: Data)
}

final class LoginUseCase {
    private let memberRepository: MemberRepositoryProtocol
    
    init(memberRepository: MemberRepositoryProtocol) {
        self.memberRepository = memberRepository
    }
}

// MARK: - LoginUseCaseProtocol Conformation
extension LoginUseCase: LoginUseCaseProtocol {
    func login(authorizationCode: Data) {
        // TODO: WIP
    }
}

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
    private let userRepository: UserRepositoryProtocol
    
    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }
}

// MARK: - LoginUseCaseProtocol Conformation
extension LoginUseCase: LoginUseCaseProtocol {
    func login(authorizationCode: Data) {
        // TODO: WIP
    }
}

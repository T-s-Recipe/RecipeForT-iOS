//
//  SignUpState.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/11/25.
//

import Foundation

@MainActor @Observable
final class SignUpState: ViewState {
    var isLoading: Bool = false
    var nicknameFieldText: String = ""
    
    var tasks: [String: Task<Void, Never>] = [:]
}

// MARK: - Interfaces
extension SignUpState {
    func updateTemporalNickname(_ text: String) {
        nicknameFieldText = text
    }
}

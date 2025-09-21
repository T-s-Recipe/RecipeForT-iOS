//
//  SignUpState.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/11/25.
//

import Foundation

@MainActor @Observable
final class SignUpState: ViewState {
    struct Constants {
        static let nicknameDuplicatedErrorMessage: String = "This nickname is already in use."
        static let nicknameLimitExceededErrorMessage: String = "Character limit exceeded."
        static let emptyNicknameErrorMessage: String = "This field is required."
    }
    
    var isLoading: Bool = false
    var nicknameFieldText: String = ""
    var nicknameValidationMessage: String?
    var continueButtonDisabled: Bool { isLoading || nicknameValidationState.isError }
    @ObservationIgnored var nicknameValidationState: NicknameValidationState = .emptyNickname
    
    var tasks: [String: Task<Void, Never>] = [:]
}

// MARK: - Interfaces
extension SignUpState {
    func updateTemporalNickname(_ text: String) {
        nicknameFieldText = text
    }
    
    func updateNicknameValidationState(_ state: NicknameValidationState) {
        self.nicknameValidationState = state
        
        switch state {
        case .valid:
            nicknameValidationMessage = nil
        case .duplicated:
            nicknameValidationMessage = Constants.nicknameDuplicatedErrorMessage
        case .limitExceeded:
            nicknameValidationMessage = Constants.nicknameLimitExceededErrorMessage
        case .emptyNickname:
            nicknameValidationMessage = Constants.emptyNicknameErrorMessage
        }
    }
}

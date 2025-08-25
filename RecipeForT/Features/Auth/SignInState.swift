//
//  SignInState.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/12/25.
//

import Foundation

@MainActor @Observable
final class SignInState: ViewState {
    var isLoading: Bool = false
    var tasks: [String: Task<Void, Never>] = [:]
}

// MARK: - Interfaces
extension SignInState {
    
}

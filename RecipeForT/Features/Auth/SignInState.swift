//
//  SignInState.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/12/25.
//

import Foundation

@MainActor @Observable
final class SignInState: ViewState {
    enum Entity: Equatable {
        case initial
        case loading
        case loaded(AuthenticationState)
        case error(FloaterItem)
    }
    
    var entity: Entity = .initial
    var tasks: [String: Task<Void, Never>] = [:]
}

// MARK: - Interfaces
extension SignInState {
    
}

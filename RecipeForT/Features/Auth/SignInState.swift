//
//  SignInState.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/12/25.
//

import Foundation

@MainActor @Observable
final class SignInState {
    enum Entity: Equatable {
        case initial
        case loading
        case loaded(AuthenticationState)
        case error(FloaterItem)
    }
    
    var entity: Entity = .initial
    private var tasks: [String: Task<Void, Never>] = [:]
}

// MARK: - Interfaces
extension SignInState {
    func cancelTask(for key: String) {
        tasks[key]?.cancel()
    }
    
    func storeTask(for key: String, task: Task<Void, Never>) {
        tasks[key] = task
    }
}

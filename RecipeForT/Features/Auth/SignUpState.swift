//
//  SignUpState.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/11/25.
//

import Foundation

@MainActor @Observable
final class SignUpState {
    enum Entity: Equatable {
        case initial
        case loading
        case loaded(AuthenticationState)
        case error(FloaterItem)
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.loading, .loading):
                return true
            case (.loaded(let lhsAuth), .loaded(let rhsAuth)):
                return lhsAuth == rhsAuth
            case (.error(let lhsItem), .error(let rhsItem)):
                return lhsItem == rhsItem
            default:
                return false
            }
        }
    }
    
    var entity: Entity = .initial
    var temporalNickname: String = ""
    var nicknameFieldText: String = ""
    
    private var tasks: [String: Task<Void, Never>] = [:]
}

// MARK: - Interfaces
extension SignUpState {
    func cancelTask(for key: String) {
        tasks[key]?.cancel()
    }
    
    func storeTask(for key: String, task: Task<Void, Never>) {
        tasks[key] = task
    }
    
    func updateTemporalNickname(_ text: String) {
        nicknameFieldText = text
        temporalNickname = text
    }
}

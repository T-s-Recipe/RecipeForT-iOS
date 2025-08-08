//
//  AuthenticationState.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/2/25.
//

import Foundation

/// 인증 상태
enum AuthenticationState {
    /// 비로그인
    case loggedOut
    /// 회원가입 대기 (임시계정 혹은 가입 절차 진행 중)
    case pendingRegistration(tokens: Tokens)
    /// 로그인
    case loggedIn(member: Member)
    
    var isRegistrationNeeded: Bool {
        switch self {
        case .loggedOut, .loggedIn: return false
        case .pendingRegistration: return true
        }
    }
}

// MARK: - Equatable Conformation
extension AuthenticationState: Equatable {
    static func == (lhs: AuthenticationState, rhs: AuthenticationState) -> Bool {
        switch (lhs, rhs) {
        case (.loggedOut, .loggedOut):
            return true
        case (.pendingRegistration(let lhsTokens), .pendingRegistration(let rhsTokens)):
            return lhsTokens.accessToken == rhsTokens.accessToken
        case (.loggedIn(let lhsMember), .loggedIn(let rhsMember)):
            return lhsMember.id == rhsMember.id
        default:
            return false
        }
    }
}

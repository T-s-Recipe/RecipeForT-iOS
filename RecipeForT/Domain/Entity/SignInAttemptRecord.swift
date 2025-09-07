//
//  SignInAttemptRecord.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/5/25.
//

import Foundation

/// 로그인 시도 기록
struct SignInAttemptRecord: Equatable {
    let idToken: String
    let provider: OAuthProvider
    let ci: String
    let userID: String?
    let tokens: Tokens?
    var isRegistrationNeeded: Bool { userID == nil || tokens == nil }
    
    static func == (lhs: SignInAttemptRecord, rhs: SignInAttemptRecord) -> Bool {
        guard lhs.idToken == rhs.idToken,
              lhs.ci == rhs.ci,
              lhs.provider == rhs.provider
        else { return false }
        return true
    }
}

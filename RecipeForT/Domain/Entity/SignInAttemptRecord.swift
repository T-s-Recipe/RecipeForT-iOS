//
//  SignInAttemptRecord.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/5/25.
//

import Foundation

/// 로그인 시도 기록
struct SignInAttemptRecord {
    let authCode: Data
    let provider: OAuthProvider
    let name: String?
    let email: String?
}

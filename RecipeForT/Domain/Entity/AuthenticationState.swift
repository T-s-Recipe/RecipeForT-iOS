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
    case pendingRegistration
    /// 로그인
    case loggedIn(member: Member)
}

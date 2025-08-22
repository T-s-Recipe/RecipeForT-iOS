//
//  Member.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/2/25.
//

import Foundation

/// 사용자 정보
struct Member: Identifiable {
    let id: String
    let nickname: String
    let provider: OAuthProvider
    let ci: String
}

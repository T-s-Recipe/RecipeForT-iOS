//
//  OAuthProvider.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/1/25.
//

import Foundation

/// 소셜로그인 공급자
enum OAuthProvider {
    case apple
    case google
    
    var identifier: String {
        switch self {
        case .apple: "APPLE"
        case .google: "GOOGLE"
        }
    }
}

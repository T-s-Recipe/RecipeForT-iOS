//
//  MemberRepositoryEnvironmentKey.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/11/25.
//

import SwiftUI

struct MemberRepositoryEnvironmentKey: EnvironmentKey {
    private static let tokenStorage = TokenStorage()
    
    static let defaultValue: MemberRepositoryProtocol = MemberRepository(
        networkService: NetworkService(tokenStorage: tokenStorage),
        tokenStorage: tokenStorage
    )
}

extension EnvironmentValues {
    var memberRepository: MemberRepositoryProtocol {
        get { self[MemberRepositoryEnvironmentKey.self] }
        set { self[MemberRepositoryEnvironmentKey.self] = newValue }
    }
}

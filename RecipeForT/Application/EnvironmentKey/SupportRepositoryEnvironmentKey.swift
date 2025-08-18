//
//  SupportRepositoryEnvironmentKey.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/18/25.
//

import SwiftUI

struct SupportRepositoryEnvironmentKey: EnvironmentKey {
    private static let tokenStorage = TokenStorage()
    
    static let defaultValue: SupportRepositoryProtocol = SupportRepository(networkService: NetworkService(tokenStorage: tokenStorage))
}

extension EnvironmentValues {
    var supportRepository: SupportRepositoryProtocol {
        get { self[SupportRepositoryEnvironmentKey.self] }
        set { self[SupportRepositoryEnvironmentKey.self] = newValue }
    }
}

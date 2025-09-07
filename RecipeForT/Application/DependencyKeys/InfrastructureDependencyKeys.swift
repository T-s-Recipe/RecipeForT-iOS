//
//  InfrastructureDependencyKeys.swift
//  RecipeForT
//
//  Created by Swain Yun on 9/2/25.
//

import Foundation
import ComposableArchitecture

extension DependencyValues {
    var tokenStorage: TokenStorageProtocol {
        get { self[TokenStorageKey.self] }
        set { self[TokenStorageKey.self] = newValue }
    }
    
    var networkService: NetworkServiceProtocol {
        get { self[NetworkServiceKey.self] }
        set { self[NetworkServiceKey.self] = newValue }
    }
}

enum TokenStorageKey: DependencyKey {
    typealias Value = TokenStorageProtocol
    
    static let liveValue: any Value = TokenStorage()
}

enum NetworkServiceKey: DependencyKey {
    typealias Value = NetworkServiceProtocol
    
    static let liveValue: any Value = NetworkService(tokenStorage: TokenStorageKey.liveValue)
}

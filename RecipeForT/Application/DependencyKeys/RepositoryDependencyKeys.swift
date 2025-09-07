//
//  RepositoryDependencyKeys.swift
//  RecipeForT
//
//  Created by Swain Yun on 9/2/25.
//

import Foundation
import ComposableArchitecture

extension DependencyValues {
    var recipeRepository: RecipeRepositoryProtocol {
        get { self[RecipeRepositoryKey.self] }
        set { self[RecipeRepositoryKey.self] = newValue }
    }
    
    var memberRepository: MemberRepositoryProtocol {
        get { self[MemberRepositoryKey.self] }
        set { self[MemberRepositoryKey.self] = newValue }
    }
    
    var supportRepository: SupportRepositoryProtocol {
        get { self[SupportRepositoryKey.self] }
        set { self[SupportRepositoryKey.self] = newValue }
    }
}

enum RecipeRepositoryKey: DependencyKey {
    typealias Value = RecipeRepositoryProtocol
    
    static let liveValue: any Value = RecipeRepository(networkService: NetworkServiceKey.liveValue)
}

enum MemberRepositoryKey: DependencyKey {
    typealias Value = MemberRepositoryProtocol
    
    static let liveValue: any Value = MemberRepository(
        networkService: NetworkServiceKey.liveValue,
        tokenStorage: TokenStorageKey.liveValue
    )
}

enum SupportRepositoryKey: DependencyKey {
    typealias Value = SupportRepositoryProtocol
    
    static let liveValue: any Value = SupportRepository(networkService: NetworkServiceKey.liveValue)
}

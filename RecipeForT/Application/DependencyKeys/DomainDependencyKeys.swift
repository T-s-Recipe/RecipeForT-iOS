//
//  DomainDependencyKeys.swift
//  RecipeForT
//
//  Created by Swain Yun on 9/2/25.
//

import Foundation
import ComposableArchitecture

extension DependencyValues {
    var authClient: AuthClient {
        get { self[AuthClient.self] }
        set { self[AuthClient.self] = newValue }
    }
    
    var recipeClient: RecipeClient {
        get { self[RecipeClient.self] }
        set { self[RecipeClient.self] = newValue }
    }
}

extension AuthClient: DependencyKey {
    static let liveValue: AuthClient = {
        let memberRepository = MemberRepositoryKey.liveValue
        let liveAuthModel = LiveAuthModel(memberRepository: memberRepository)
        
        return Self {
            liveAuthModel.stream
        } login: { idToken, provider in
            try await liveAuthModel.login(idToken: idToken, provider: provider)
        } logout: {
            await liveAuthModel.logout()
        } register: { record, nickname in
            try await liveAuthModel.register(record: record, nickname: nickname)
        } unregister: {
            try await liveAuthModel.unregister()
        } fetchRandomNickname: {
            try await liveAuthModel.fetchRandomNickname()
        } validateNickname: { nickname in
            try await liveAuthModel.validateNickname(nickname)
        }
    }()
}

extension RecipeClient: DependencyKey {
    static let liveValue: RecipeClient = {
        let recipeRepository = RecipeRepositoryKey.liveValue
        
        return Self { userID, title, image, servings, cost, cookingTime, notes, basicIngredients, sources, detailedSteps in
            try await recipeRepository.create(userID: userID, title: title, image: image, servings: servings, cost: cost, cookingTime: cookingTime, notes: notes, basicIngredients: basicIngredients, sources: sources, detailedSteps: detailedSteps)
        } readPage: { pageID, limit in
            try await recipeRepository.read(pageID: pageID, limit: limit)
        } readRecipe: { recipeID in
            try await recipeRepository.read(recipeID: recipeID)
        } uploadImage: { item in
            try await recipeRepository.uploadRecipeImage(item)
        }
    }()
}

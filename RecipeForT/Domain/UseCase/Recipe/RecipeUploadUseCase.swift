//
//  RecipeUploadUseCase.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/6/25.
//

import Foundation

final class RecipeUploadUseCase {
    private let memberRepository: MemberRepositoryProtocol
    private let recipeRepository: RecipeRepositoryProtocol
    
    init(
        memberRepository: MemberRepositoryProtocol,
        recipeRepository: RecipeRepositoryProtocol
    ) {
        self.memberRepository = memberRepository
        self.recipeRepository = recipeRepository
    }
}

// MARK: - Interfaces
extension RecipeUploadUseCase {
    func execute(
        _ title: String,
        _ image: Data?,
        servings: Decimal?,
        cost: Decimal?,
        cookingTime: Decimal?,
        notes: String,
        basicIngredients: [Ingredient],
        sources: [Ingredient],
        detailedSteps: [CookingStep]
    ) async throws {
        let authenticationState = try await memberRepository.fetchMember()
        guard case .loggedIn(let member) = authenticationState else { throw MemberRepositoryError.authenticationFailed }
        
        return try await recipeRepository.create(
            userID: member.id,
            title: title,
            image: image,
            servings: servings,
            cost: cost,
            cookingTime: cookingTime,
            notes: notes,
            basicIngredients: basicIngredients,
            sources: sources,
            detailedSteps: detailedSteps
        )
    }
}

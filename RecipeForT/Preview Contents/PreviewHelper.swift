//
//  PreviewHelper.swift
//  RecipeForT
//
//  Created by Swain Yun on 6/11/25.
//

import Foundation

final class PreviewHelper {
    static let shared = PreviewHelper()
    
    let router = Router()
    
    lazy var mockRecipe = Recipe(
        id: 0,
        authorID: 123,
        name: "Brocolli",
        imageURL: nil,
        servingsCount: 3,
        cost: 4,
        cookingTime: 15,
        description: "기타 메모는 여기에.\n참고한 레시피 원본 출저 등의 내용 적으면 됨",
        ingredients: [mockIngredient]
    )
    
    lazy var mockIngredient = Ingredient(
        name: "브로콜리",
        unit: .count(2)
    )
    
    private init() {}
}

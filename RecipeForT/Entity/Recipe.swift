//
//  Recipe.swift
//  RecipeForT
//
//  Created by Swain Yun on 6/10/25.
//

import Foundation

/// 레시피
struct Recipe: Identifiable {
    /// 고유 식별자
    let id: UInt64
    /// 레시피 작성자 식별자
    let authorID: UInt64
    /// 레시피 또는 음식의 이름
    let name: String
    /// 대표 이미지 URL
    let imageURL: URL?
    /// n인분, 인당 식사 분량
    let servingsCount: UInt8
    /// 조리비용
    let cost: Decimal
    /// 조리시간(분)
    let cookingTime: UInt8
    /// 레시피에 대한 설명
    let description: String
    /// 재료 목록
    let ingredients: [Ingredient]
}

/// 음식 재료
struct Ingredient {
    /// 재료 이름
    let name: String
    /// 계량 단위
    let unit: IngredientUnit
}

/// 계량 단위
enum IngredientUnit {
    case count(Double)
    case gram(Double)
    case milliliter(Double)
    case tablespoon(Double)
    case teaspoon(Double)
}

/// 조리과정 단계적 구분
enum CookingStep {
    // 재료손질
    // 양념만들기
    // 조리
}

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
    
    init(
        id: UInt64 = .zero,
        authorID: UInt64 = .zero,
        name: String = "",
        imageURL: URL? = nil,
        servingsCount: UInt8 = .zero,
        cost: Decimal = .zero,
        cookingTime: UInt8 = .zero,
        description: String = "",
        ingredients: [Ingredient] = []
    ) {
        self.id = id
        self.authorID = authorID
        self.name = name
        self.imageURL = imageURL
        self.servingsCount = servingsCount
        self.cost = cost
        self.cookingTime = cookingTime
        self.description = description
        self.ingredients = ingredients
    }
    
    static var sample: Recipe { .init() }
}

/// 음식 재료
struct Ingredient {
    /// 재료 이름
    let name: String
    /// 계량 단위
    var units: [IngredientUnit]
}

struct IngredientUnit {
    let measurement: MeasurementUnit
    let ammount: Double
}

/// 계량 단위
enum MeasurementUnit: CaseIterable {
    /// 테이블스푼
    ///
    /// 주로 액체나 반고체 재료(예: 기름, 버터)를 계량
    ///
    /// 1 Tbsp는 약 15ml
    case tablespoon
    /// 수량
    ///
    /// 특정 단위 없이 개수나 양을 나타낼 때 사용
    case quantity
    /// 컵
    ///
    /// 고체(밀가루), 액체(물) 모두 계량 가능한 단위
    ///
    /// 1 Cup은 약 240ml, 8 fl oz
    case cup
    /// 그램
    ///
    /// 질량 단위로, 정밀한 계량에 사용하며 주로 고체 재료에 적합
    case gram
    /// 밀리미터
    ///
    /// 부피 단위로, 액체 재료를 계량할 때 사용
    case milliliters
    /// 온스
    ///
    /// 미국식 무게 또는 부피 단위로 문맥에 따라 fl oz로 액체를, 그냥 oz로 고체를 나타냄
    case ounce
    
    var short: String {
        switch self {
        case .tablespoon: return "Tbsp"
        case .quantity: return "Qty"
        case .cup: return "Cup"
        case .gram: return "g"
        case .milliliters: return "ml"
        case .ounce: return "oz"
        }
    }
}

/// 조리과정 단계적 구분
enum CookingStep {
    // 재료손질
    // 양념만들기
    // 조리
}

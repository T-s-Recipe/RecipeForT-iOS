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
struct Ingredient: Identifiable {
    let id: UUID = UUID()
    /// 재료 이름
    var name: String
    /// 계량 단위
    var units: MeasurementUnitDataSource
}

struct MeasurementUnitDataSource {
    var quantity: Decimal?
    var tablespoon: Decimal?
    var teaspoon: Decimal?
    var cup: Decimal?
    var gram: Decimal?
    var milliliters: Decimal?
    var ounce: Decimal?
    
    subscript(_ unit: MeasurementUnit) -> Decimal? {
        get {
            switch unit {
            case .quantity: quantity
            case .tablespoon: tablespoon
            case .teaspoon: teaspoon
            case .cup: cup
            case .gram: gram
            case .milliliters: milliliters
            case .ounce: ounce
            }
        }
        
        set {
            switch unit {
            case .quantity: self.quantity = newValue
            case .tablespoon: self.tablespoon = newValue
            case .teaspoon: self.teaspoon = newValue
            case .cup: self.cup = newValue
            case .gram: self.gram = newValue
            case .milliliters: self.milliliters = newValue
            case .ounce: self.ounce = newValue
            }
        }
    }
}

/// 계량 단위
enum MeasurementUnit: CaseIterable {
    case quantity
    case tablespoon
    case teaspoon
    case cup
    case gram
    case milliliters
    case ounce
    
    var short: String {
        switch self {
        case .tablespoon: return "Tbsp"
        case .teaspoon: return "Tsp"
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

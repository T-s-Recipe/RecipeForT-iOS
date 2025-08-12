//
//  Recipe.swift
//  RecipeForT
//
//  Created by Swain Yun on 6/10/25.
//

import Foundation

/// 레시피
@Observable
final class Recipe: Identifiable, Equatable {
    /// 고유 식별자
    let id: String
    /// 레시피 작성자 식별자
    let authorID: String
    /// 레시피 작성자 이름
    let authorNickname: String
    /// 레시피 또는 음식의 이름
    let name: String
    /// 대표 이미지 URL
    let imageURL: URL?
    /// n인분, 인당 식사 분량
    let servingsCount: Decimal?
    /// 조리비용
    let cost: Decimal?
    /// 조리시간(분)
    let cookingTime: Decimal?
    /// 레시피에 대한 설명
    let description: String
    /// 재료 목록
    let ingredients: [Ingredient]
    /// 소스 목록
    let sources: [Ingredient]
    /// 조리과정 목록
    let detailedSteps: [CookingStep]
    
    init(
        id: String = UUID().uuidString,
        authorID: String = "",
        authorNickname: String = "",
        name: String = "",
        imageURL: URL? = nil,
        servingsCount: Decimal? = nil,
        cost: Decimal? = nil,
        cookingTime: Decimal? = nil,
        description: String = "",
        ingredients: [Ingredient] = [.init(name: "", units: .init())],
        sources: [Ingredient] = [.init(name: "", units: .init())],
        detailedSteps: [CookingStep] = [.init(title: "Step 1", detailedProcesses: [.init(description: "")])]
    ) {
        self.id = id
        self.authorID = authorID
        self.authorNickname = authorNickname
        self.name = name
        self.imageURL = imageURL
        self.servingsCount = servingsCount
        self.cost = cost
        self.cookingTime = cookingTime
        self.description = description
        self.ingredients = ingredients
        self.sources = sources
        self.detailedSteps = detailedSteps
    }
    
    static var sample: Recipe { .init() }
    
    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        lhs.id == rhs.id
    }
}

/// 음식 재료
struct Ingredient: Identifiable, Equatable {
    let id: UUID = UUID()
    /// 재료 이름
    var name: String
    /// 계량 단위
    var units: MeasurementUnitDataSource
    
    static func == (lhs: Ingredient, rhs: Ingredient) -> Bool {
        lhs.id == rhs.id
    }
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

/// 조리과정
struct CookingStep: Identifiable, Equatable {
    let id: UUID = UUID()
    var title: String
    var detailedProcesses: [CookingDetailedProcess]
    
    init(title: String, detailedProcesses: [CookingDetailedProcess] = [.init(description: "")]) {
        self.title = title
        self.detailedProcesses = detailedProcesses
    }
    
    static func == (lhs: CookingStep, rhs: CookingStep) -> Bool {
        lhs.id == rhs.id
    }
}

/// 조리과정 세부단계
struct CookingDetailedProcess: Identifiable {
    let id: UUID = UUID()
    let imageURL: URL?
    var image: Data?
    var description: String
    
    init(imageURL: URL? = nil, image: Data? = nil, description: String) {
        self.imageURL = imageURL
        self.image = image
        self.description = description
    }
}

struct RecipePage {
    let recipes: [Recipe]
    let nextPageID: String?
}

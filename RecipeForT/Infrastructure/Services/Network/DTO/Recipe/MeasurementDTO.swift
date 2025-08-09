//
//  MeasurementDTO.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/9/25.
//

import Foundation

struct MeasurementDTO: Codable {
    let ammount: Decimal
    let unit: Unit
    
    init(ammount: Decimal, unit: Unit) {
        self.ammount = ammount
        self.unit = unit
    }
    
    init(ammount: Decimal, measurementUnit: MeasurementUnit) {
        self.ammount = ammount
        self.unit = Self.initializeUnit(measurementUnit)
    }
    
    static func initializeUnit(_ unit: MeasurementUnit) -> Unit {
        switch unit {
        case .quantity: return .quantity
        case .tablespoon: return .tablespoon
        case .teaspoon: return .teaspoon
        case .cup: return .cup
        case .gram: return .gram
        case .milliliters: return .milliliter
        case .ounce: return .ounce
        }
    }
}

extension MeasurementDTO {
    enum Unit: String, Codable {
        case gram = "GRAM"
        case milliliter = "MILLILITER"
        case tablespoon = "TABLESPOON"
        case teaspoon = "TEASPOON"
        case cup = "CUP"
        case ounce = "OZ"
        case quantity = "QUANTITY"
        
        var toMeasurementUnit: MeasurementUnit {
            switch self {
            case .quantity: .quantity
            case .tablespoon: .tablespoon
            case .teaspoon: .teaspoon
            case .cup: .cup
            case .gram: .gram
            case .milliliter: .milliliters
            case .ounce: .ounce
            }
        }
    }
}

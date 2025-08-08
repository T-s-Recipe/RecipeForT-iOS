//
//  CreateRecipeRequestDTO.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/6/25.
//

import Foundation

struct CreateRecipeRequestDTO: Encodable {
    let authorID: String
    let title: String
    let servings: Decimal
    let cost: Decimal?
    let cookingTime: Decimal?
    let notes: String
    let basicIngredients: [IngredientDTO]
    let sources: [IngredientDTO]
    let detailedSteps: [StepDTO]
    
    init(
        authorID: String,
        title: String,
        servings: Decimal?,
        cost: Decimal?,
        cookingTime: Decimal?,
        notes: String,
        basicIngredients: [IngredientDTO],
        sources: [IngredientDTO],
        detailedSteps: [StepDTO]
    ) {
        self.authorID = authorID
        self.title = title
        self.servings = servings ?? 4
        self.cost = cost
        self.cookingTime = cookingTime
        self.notes = notes
        self.basicIngredients = basicIngredients
        self.sources = sources
        self.detailedSteps = detailedSteps
    }
    
    init(
        authorID: String,
        title: String,
        servings: Decimal?,
        cost: Decimal?,
        cookingTime: Decimal?,
        notes: String,
        basicIngredients: [Ingredient],
        sources: [Ingredient],
        detailedSteps: [CookingStep]
    ) {
        self.authorID = authorID
        self.title = title
        self.servings = servings ?? 4
        self.cost = cost
        self.cookingTime = cookingTime
        self.notes = notes
        self.basicIngredients = basicIngredients.map { .init(name: $0.name, measurements: $0.units) }
        self.sources = sources.map { .init(name: $0.name, measurements: $0.units)}
        self.detailedSteps = detailedSteps.map { .init(title: $0.title, process: $0.detailedProcesses) }
    }
    
    enum CodingKeys: String, CodingKey {
        case title, servings, cost, cookingTime, basicIngredients
        case authorID = "authorId"
        case notes = "memo"
        case sources = "sourceIngredients"
    }
}

struct IngredientDTO: Encodable {
    let name: String
    let measurements: [MeasurementDTO]
    
    init(name: String, measurements: [MeasurementDTO]) {
        self.name = name
        self.measurements = measurements
    }
    
    init(name: String, measurements: MeasurementUnitDataSource) {
        self.name = name
        self.measurements = initializeMeasurements(measurements)
    }
    
    private func initializeMeasurements(_ measurement: MeasurementUnitDataSource) -> [MeasurementDTO] {
        var measurements = [MeasurementDTO]()
        
        if let quantity = measurement.quantity {
            measurements.append(MeasurementDTO(ammount: quantity, unit: .quantity))
        }
        
        if let tablespoon = measurement.tablespoon {
            measurements.append(MeasurementDTO(ammount: tablespoon, unit: .tablespoon))
        }
        
        if let teaspoon = measurement.teaspoon {
            measurements.append(MeasurementDTO(ammount: teaspoon, unit: .teaspoon))
        }
        
        if let cup = measurement.cup {
            measurements.append(MeasurementDTO(ammount: cup, measurementUnit: .cup))
        }
        
        if let gram = measurement.gram {
            measurements.append(MeasurementDTO(ammount: gram, unit: .gram))
        }
        
        if let milliliters = measurement.milliliters {
            measurements.append(MeasurementDTO(ammount: milliliters, unit: .milliliter))
        }
        
        if let ounce = measurement.ounce {
            measurements.append(MeasurementDTO(ammount: ounce, measurementUnit: .ounce))
        }
        
        return measurements
    }
}

struct MeasurementDTO: Encodable {
    let ammount: Decimal
    let unit: Unit
    
    init(ammount: Decimal, unit: Unit) {
        self.ammount = ammount
        self.unit = unit
    }
    
    init(ammount: Decimal, measurementUnit: MeasurementUnit) {
        self.ammount = ammount
        self.unit = initializeUnit(measurementUnit)
    }
    
    private func initializeUnit(_ unit: MeasurementUnit) -> Unit {
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
    enum Unit: String, Encodable {
        case gram = "GRAM"
        case milliliter = "MILLILITER"
        case tablespoon = "TABLESPOON"
        case teaspoon = "TEASPOON"
        case cup = "CUP"
        case ounce = "OZ"
        case quantity = "QUANTITY"
    }
}

struct StepDTO: Encodable {
    let title: String
    let process: [Process]
    
    init(title: String, process: [Process]) {
        self.title = title
        self.process = process
    }
    
    init(title: String, process: [CookingDetailedProcess]) {
        self.title = title
        self.process = process.map { .init(content: $0.description) }
    }
}

extension StepDTO {
    struct Process: Encodable {
        let content: String
    }
}

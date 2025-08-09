//
//  IngredientDTO.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/9/25.
//

import Foundation

struct IngredientDTO: Codable {
    let name: String
    let measurements: [MeasurementDTO]
    
    init(name: String, measurements: [MeasurementDTO]) {
        self.name = name
        self.measurements = measurements
    }
    
    init(name: String, measurements: MeasurementUnitDataSource) {
        self.name = name
        self.measurements = Self.initializeMeasurements(measurements)
    }
    
    static func initializeMeasurements(_ measurement: MeasurementUnitDataSource) -> [MeasurementDTO] {
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
    
    func toEntity() -> Ingredient {
        var units = MeasurementUnitDataSource()
        measurements.forEach { units[$0.unit.toMeasurementUnit] = $0.ammount }
        return Ingredient(name: name, units: units)
    }
}

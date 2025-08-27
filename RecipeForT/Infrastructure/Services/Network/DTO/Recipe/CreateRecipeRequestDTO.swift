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
    let imageURL: URL?
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
        imageURL: URL?,
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
        self.imageURL = imageURL
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
        imageURL: URL?,
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
        self.imageURL = imageURL
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
        case imageURL = "imageUrl"
        case authorID = "authorId"
        case notes = "memo"
        case sources = "sourceIngredients"
    }
}

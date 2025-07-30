//
//  PreviewHelper.swift
//  RecipeForT
//
//  Created by Swain Yun on 6/11/25.
//

import Foundation
import Swinject

final class PreviewHelper {
    static let shared = PreviewHelper()
    
    lazy var router = Router(resolver: resolver)
    
    lazy var resolver: Resolver = {
        let assembler = Assembler([
            PresentationAssembly(),
            DomainAssembly(),
            RepositoryAssembly(),
            InfrastructureAssembly()
        ])
        return assembler.resolver
    }()
    
    lazy var mockRecipe = Recipe(
        id: 0,
        authorID: 123,
        name: "Brocolli",
        imageURL: nil,
        servingsCount: nil,
        cost: 4,
        cookingTime: 15,
        description: "기타 메모는 여기에.\n참고한 레시피 원본 출저 등의 내용 적으면 됨",
        ingredients: mockIngredients,
        detailedSteps: mockSteps
    )
    
    lazy var mockIngredients: [Ingredient] = [
        .init(name: "브로콜리", units: .init(quantity: 1, tablespoon: 2, teaspoon: 3, cup: 4, gram: 300, milliliters: 324, ounce: 432)),
        .init(name: "Tofu", units: .init()),
        .init(name: "chopped onion", units: .init())
    ]
    
    lazy var mockSteps: [CookingStep] = [
        .init(title: "Step 1", detailedProcesses: detailedProcesses),
        .init(title: "Step 2", detailedProcesses: detailedProcesses),
        .init(title: "Step 3", detailedProcesses: detailedProcesses),
    ]
    
    lazy var detailedProcesses: [CookingDetailedProcess] = [
        .init(imageURL: nil, description: "Wash garlics"),
        .init(imageURL: nil, description: "Stir the garlics with a spoon of oil Stir the garlics with a spoon of oil"),
        .init(imageURL: nil, description: "Chop broccoli into small pieces")
    ]
    
    private init() {}
}

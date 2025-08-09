//
//  RecipeListResponseDTO.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/9/25.
//

import Foundation

/**
 Recipe Pagenation 응답 DTO
 
 ```json
 {
   "resultList": [
     {
       "authorId": "string",
       "authorName": "string",
       "title": "string",
       "imageUrl": "string",
       "servings": 0,
       "cost": 0,
       "cookingTime": 0
     }
   ],
   "nextCursorId": "string"
 }
 ```
 */
struct RecipeListResponseDTO: Decodable {
    let recipes: [RecipeDTO]
    let nextCursorID: String?
    
    enum CodingKeys: String, CodingKey {
        case recipes = "resultList"
        case nextCursorID = "nextCursorId"
    }
    
    func toEntity() -> RecipePage {
        let recipes = recipes.map { $0.toEntity() }
        return .init(recipes: recipes, nextPageID: nextCursorID)
    }
}

extension RecipeListResponseDTO {
    struct RecipeDTO: Decodable {
        let authorID, authorNickname, title: String
        let imageURL: URL?
        let servings, cost, cookingTime: Decimal?
        
        enum CodingKeys: String, CodingKey {
            case title, servings, cost, cookingTime
            case authorID = "authorId"
            case authorNickname = "authorName"
            case imageURL = "imageUrl"
        }
        
        func toEntity() -> Recipe {
            .init(
                authorID: authorID,
                authorNickname: authorNickname,
                name: title,
                imageURL: imageURL,
                servingsCount: servings,
                cost: cost,
                cookingTime: cookingTime,
                ingredients: [],
                sources: [],
                detailedSteps: []
            )
        }
    }
}

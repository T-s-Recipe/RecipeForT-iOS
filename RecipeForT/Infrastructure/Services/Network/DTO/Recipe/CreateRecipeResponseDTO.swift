//
//  CreateRecipeResponseDTO.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/9/25.
//

import Foundation

/**
 Recipe Upload 응답 DTO
 
 ```json
 {
   "id": "string",
   "authorId": "string",
   "authorNickname": "string",
   "title": "string",
   "imageUrl": "string",
   "servings": 0,
   "cost": 0,
   "cookingTime": 0,
   "memo": "string",
   "basicIngredients": [
     {
       "name": "string",
       "measurements": [
         {
           "amount": 0,
           "unit": "string"
         }
       ]
     }
   ],
   "sourceIngredients": [
     {
       "name": "string",
       "measurements": [
         {
           "amount": 0,
           "unit": "string"
         }
       ]
     }
   ],
   "steps": [
     {
       "title": "string",
       "steps": [
         {
           "content": "string"
         }
       ]
     }
   ]
 }
 ```
 */
struct CreateRecipeResponseDTO: Decodable {
    let id, authorID, authorNickname, title: String
    let imageURLString: String?
    let servings, cost, cookingTime: Decimal?
    let description: String
    let basicIngredients, sources: [IngredientDTO]
    let detailedSteps: [StepDTO]
    
    enum CodingKeys: String, CodingKey {
        case id, authorNickname, title, servings, cost, cookingTime, basicIngredients
        case authorID = "authorId"
        case imageURLString = "imageUrl"
        case description = "memo"
        case sources = "sourceIngredients"
        case detailedSteps = "steps"
    }
}

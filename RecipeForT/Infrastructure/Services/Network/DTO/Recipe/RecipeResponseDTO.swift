//
//  RecipeResponseDTO.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/9/25.
//

import Foundation

/**
 Recipe 단건 조회 (레시피 상세 정보) 응답 DTO
 
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
struct RecipeResponseDTO: Decodable {
    let id, authorID, authorNickname, title: String
    let imageURL: URL?
    let servings, cost, cookingTime: Decimal
    let description: String
    let basicIngredients, sources: [IngredientDTO]
    let steps: [StepDTO]
    
    enum CodingKeys: String, CodingKey {
        case id, authorNickname, title, servings, cost, cookingTime, basicIngredients, steps
        case authorID = "authorId"
        case imageURL = "imageUrl"
        case description = "memo"
        case sources = "sourceIngredients"
    }
}

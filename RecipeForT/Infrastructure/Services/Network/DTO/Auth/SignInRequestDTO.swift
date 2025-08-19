//
//  SignInRequestDTO.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/2/25.
//

import Foundation

struct SignInRequestDTO: Encodable {
    let idToken: String
    let providerIdentifier: String
    
    enum CodingKeys: String, CodingKey {
        case idToken
        case providerIdentifier = "provider"
    }
}

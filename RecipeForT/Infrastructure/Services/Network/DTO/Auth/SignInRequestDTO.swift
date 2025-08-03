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
    let name: String?
    let email: String?
    
    enum CodingKeys: String, CodingKey {
        case idToken, name, email
        case providerIdentifier = "provider"
    }
}

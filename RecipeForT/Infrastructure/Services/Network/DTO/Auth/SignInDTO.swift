//
//  SignInDTO.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/1/25.
//

import Foundation

enum SignInDTO {
    struct Request: Encodable {
        let idToken: String
        let providerIdentifier: String
        let name: String?
        let email: String?
        
        enum CodingKeys: String, CodingKey {
            case idToken, name, email
            case providerIdentifier = "provider"
        }
    }
    
    struct Response: Decodable {
        let accessToken: String
        let refreshToken: String
    }
}

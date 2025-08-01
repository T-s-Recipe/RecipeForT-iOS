//
//  RegisterDTO.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/1/25.
//

import Foundation

enum RegisterDTO {
    struct Request: Encodable {
        let providerIdentifier: String
        let authIdentifier: String
        let name: String?
        let email: String?
        let nickname: String
        
        enum CodingKeys: String, CodingKey {
            case name, email, nickname
            case providerIdentifier = "oauthProvider"
            case authIdentifier = "oauthId"
        }
    }
    
    struct Response: Decodable {
        let id: String
        let providerIdentifier: String
        let authIdentifier: String
        let name: String?
        let email: String?
        let nickname: String
        
        enum CodingKeys: String, CodingKey {
            case id, name, email, nickname
            case providerIdentifier = "oauthProvider"
            case authIdentifier = "oauthId"
        }
    }
}

//
//  SignUpRequestDTO.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/2/25.
//

import Foundation

struct SignUpRequestDTO: Encodable {
    let providerIdentifier: String
    let ci: String
    let name: String?
    let email: String?
    let nickname: String
    
    enum CodingKeys: String, CodingKey {
        case name, email, nickname
        case providerIdentifier = "oauthProvider"
        case ci = "oauthId"
    }
}

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
    let nickname: String
    
    enum CodingKeys: String, CodingKey {
        case nickname
        case providerIdentifier = "oAuthProvider"
        case ci = "oAuthId"
    }
}

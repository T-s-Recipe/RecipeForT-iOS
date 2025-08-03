//
//  MemberResponseDTO.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/2/25.
//

import Foundation

struct MemberResponseDTO: Decodable {
    let id: String
    let providerIdentifier: String
    let authID: String
    let name: String?
    let email: String?
    let nickname: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, email, nickname
        case providerIdentifier = "oauthProvider"
        case authID = "oauthId"
    }
}

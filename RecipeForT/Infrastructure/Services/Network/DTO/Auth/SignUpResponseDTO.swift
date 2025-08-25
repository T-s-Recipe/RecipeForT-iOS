//
//  SignUpResponseDTO.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/25/25.
//

import Foundation

struct SignUpResponseDTO: Decodable {
    let userID: String
    let providerIdentifier: String
    let ci: String
    let nickname: String
    let isVerified: Bool
    
    enum CodingKeys: String, CodingKey {
        case nickname, isVerified
        case userID = "id"
        case providerIdentifier = "oauthProvider"
        case ci = "oauthId"
    }
    
    func toEntity() -> Member {
        .init(
            id: userID,
            nickname: nickname,
            provider: .init(identifier: providerIdentifier)!,
            ci: ci
        )
    }
}

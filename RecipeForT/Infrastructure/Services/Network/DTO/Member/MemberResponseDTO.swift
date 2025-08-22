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
    let ci: String
    let nickname: String
    
    enum CodingKeys: String, CodingKey {
        case id, nickname
        case providerIdentifier = "oauthProvider"
        case ci = "oauthId"
    }
    
    func toEntity() -> Member {
        .init(id: id, nickname: nickname, provider: .init(identifier: providerIdentifier)!, ci: ci)
    }
}

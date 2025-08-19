//
//  SignInResponseDTO.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/19/25.
//

import Foundation

struct SignInResponseDTO: Decodable {
    let accessToken: String?
    let refreshToken: String?
    let ci: String
    let isRegistered: Bool
    let member: MemberResponseDTO?
    
    enum CodingKeys: String, CodingKey {
        case accessToken, refreshToken
        case ci = "oAuthId"
        case isRegistered = "isMember"
        case member = "memberResponse"
    }
}

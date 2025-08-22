//
//  SignInResponseDTO.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/19/25.
//

import Foundation

struct SignInResponseDTO: Decodable {
    let authTokenResponse: AuthTokenResponseDTO?
    let ci: String
    let isRegistered: Bool
    
    enum CodingKeys: String, CodingKey {
        case authTokenResponse = "tokenResponse"
        case ci = "oauthId"
        case isRegistered = "isMember"
    }
}

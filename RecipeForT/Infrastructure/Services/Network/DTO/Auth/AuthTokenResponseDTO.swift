//
//  AuthTokenResponseDTO.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/2/25.
//

import Foundation

struct AuthTokenResponseDTO: Decodable {
    let accessToken: String
    let refreshToken: String
}

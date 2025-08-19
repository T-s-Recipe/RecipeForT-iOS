//
//  SignUpResponseDTO.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/20/25.
//

import Foundation

struct SignUpResponseDTO: Decodable {
    let accessToken: String
    let refreshToken: String
    let member: MemberResponseDTO
}

//
//  ReissueTokenDTO.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/1/25.
//

import Foundation

enum ReissueTokenDTO {
    struct Request: Encodable {
        let refreshToken: String
    }
    
    struct Response: Decodable {
        let accessToken: String
        let refreshToken: String
    }
}

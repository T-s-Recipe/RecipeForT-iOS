//
//  LogoutDTO.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/1/25.
//

import Foundation

enum LogoutDTO {
    struct Request: Encodable {
        let refreshToken: String
    }
}

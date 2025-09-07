//
//  ImageUploadResponseDTO.swift
//  RecipeForT
//
//  Created by Swain Yun on 9/7/25.
//

import Foundation

struct ImageUploadResponseDTO: Decodable {
    let uploadURL: URL
    let fileKey: String
    let imageURL: URL
    let uploadHeaders: ImageUploadResponseHeadersDTO
}

struct ImageUploadResponseHeadersDTO: Decodable {
    let contentType: String
    let host: String
    
    enum CodingKeys: String, CodingKey {
        case contentType = "Content-Type"
        case host = "Host"
    }
}

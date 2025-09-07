//
//  ImageUploadRequestDTO.swift
//  RecipeForT
//
//  Created by Swain Yun on 9/7/25.
//

import Foundation

struct ImageUploadRequestDTO: Encodable {
    let fileName: String
    let mimeType: String
    
    enum CodingKeys: String, CodingKey {
        case fileName
        case mimeType = "contentType"
    }
}

//
//  Recipe.swift
//  RecipeForT
//
//  Created by Swain Yun on 6/10/25.
//

import Foundation

/// 레시피
struct Recipe: Identifiable {
    /// 고유식별자
    let id: UInt64
    /// 레시피 또는 음식의 이름
    let title: String
    /// 대표 이미지 URL
    let imageURL: URL?
    /// n인분, 인당 식사 분량
    let servingsCount: UInt8
    /// 조리비용
    let cost: Decimal
    /// 조리시간
    let cookingTime: TimeInterval
    /// 레시피 등재자 이름
    let ownerName: String
}

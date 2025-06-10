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
    /// 기타 레시피에 대한 설명 등의 부가정보
    let additionalInformation: String
    
    static func mock() -> Self {
        .init(id: 0, title: "브로콜리 두부 무침", imageURL: nil, servingsCount: 3, cost: 4000, cookingTime: 15, ownerName: "홍길동", additionalInformation: "기타 메모는 여기에. 참고한 레시피 원본 출저 등의 내용 적으면 됨")
    }
}

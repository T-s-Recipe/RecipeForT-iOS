//
//  Color.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/24/25.
//

import SwiftUI

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}

extension ShapeStyle where Self == Color {
    static func hex(_ value: UInt) -> Color { Color(hex: value) }
}

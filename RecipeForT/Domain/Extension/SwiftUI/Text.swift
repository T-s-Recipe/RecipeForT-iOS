//
//  Text.swift
//  RecipeForT
//
//  Created by Swain Yun on 7/29/25.
//

import SwiftUI

// MARK: - Text + BulletPoint
extension Text {
    func bulletPoint() -> some View {
        modifier(BulletPointModifier())
    }
}

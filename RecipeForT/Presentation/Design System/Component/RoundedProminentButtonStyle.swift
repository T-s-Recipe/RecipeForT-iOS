//
//  RoundedProminentButtonStyle.swift
//  RecipeForT
//
//  Created by Swain Yun on 6/8/25.
//

import SwiftUI

struct RoundedProminentButtonStyle: ButtonStyle {
    let disabled: Bool
    let foregroundColor: Color
    let backgroundColor: Color
    let isLoading: Bool
    
    init(
        _ disabled: Bool,
        _ foregroundColor: Color,
        _ backgroundColor: Color,
        _ isLoading: Bool
    ) {
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.disabled = disabled || isLoading
        self.isLoading = isLoading
    }
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            if isLoading {
                ProgressView()
                    .tint(foregroundColor)
            } else {
                configuration.label
            }
        }
        .foregroundStyle(foregroundColor)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(disabled ? .gray : backgroundColor)
        )
    }
}

extension ButtonStyle where Self == RoundedProminentButtonStyle {
    static func roundedProminent(
        disabled: Bool = false,
        foreground: Color = .white,
        background: Color = .gray,
        isLoading: Bool = false
    ) -> RoundedProminentButtonStyle {
        RoundedProminentButtonStyle(disabled, foreground, background, isLoading)
    }
}


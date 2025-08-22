//
//  BackButton.swift
//  RecipeForT
//
//  Created by Swain Yun on 6/15/25.
//

import SwiftUI

struct BackButton: View {
    enum Style {
        case arrow, xmark
    }
    
    @Environment(\.dismiss) private var dismiss
    
    let style: Style
    
    init(_ style: Style = .arrow) {
        self.style = style
    }
    
    var body: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: systemName)
                .resizable()
                .frame(width: 14, height: 14)
        }
        .tint(.black)
        .padding(10)
    }
    
    private var systemName: String {
        switch style {
        case .arrow: "arrow.left"
        case .xmark: "xmark"
        }
    }
}

#Preview {
    BackButton()
        .border(.red)
}

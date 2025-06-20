//
//  BackButton.swift
//  RecipeForT
//
//  Created by Swain Yun on 6/15/25.
//

import SwiftUI

struct BackButton: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "arrow.left")
                .resizable()
                .frame(width: 24, height: 24)
        }
    }
}

#Preview {
    BackButton()
        .background(.black)
}

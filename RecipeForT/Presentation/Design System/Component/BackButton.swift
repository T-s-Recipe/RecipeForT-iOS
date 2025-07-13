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
                .frame(width: 14, height: 14)
        }
        .tint(.black)
        .padding(10)
    }
}

#Preview {
    BackButton()
        .border(.red)
}

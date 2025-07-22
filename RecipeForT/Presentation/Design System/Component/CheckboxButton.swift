//
//  CheckboxButton.swift
//  RecipeForT
//
//  Created by Swain Yun on 7/21/25.
//

import SwiftUI

struct CheckboxButtonStyle: ButtonStyle {
    var isOn: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(isOn ? .black : .clear)
            .strokeBorder(.gray)
            .frame(width: 16, height: 16)
            .overlay(alignment: .center) {
                Image(systemName: "checkmark")
                    .resizable()
                    .frame(width: 10.62, height: 7.62)
                    .bold()
                    .foregroundStyle(isOn ? .white : .clear)
            }
    }
}

struct CheckboxButton: View {
    @Binding var isOn: Bool
    
    var body: some View {
        Button("Not sure") {
            isOn.toggle()
        }
        .buttonStyle(CheckboxButtonStyle(isOn: isOn))
    }
}

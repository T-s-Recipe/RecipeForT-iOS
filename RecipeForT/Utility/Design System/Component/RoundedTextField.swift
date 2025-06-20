//
//  RoundedTextField.swift
//  RecipeForT
//
//  Created by Swain Yun on 6/20/25.
//

import SwiftUI

struct RoundedTextFieldStyle: TextFieldStyle {
    let lineColor: Color
    let disabled: Bool
    let font: Font
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .foregroundStyle(.gray)
            .frame(minHeight: 44)
            .overlay(alignment: .center) {
                RoundedRectangle(cornerRadius: 5)
                    .strokeBorder(lineColor)
            }
            .background {
                RoundedRectangle(cornerRadius: 5)
                    .foregroundStyle(disabled ? .gray : .clear)
                    .opacity(disabled ? 0.4 : 1.0)
            }
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .replaceDisabled()
    }
}

struct RoundedTextField: View {
    private let titleKey: String
    private let text: Binding<String>
    private let prompt: Text
    private let axis: Axis
    private let textFieldStyle: RoundedTextFieldStyle
    
    init(
        _ titleKey: String,
        text: Binding<String>,
        font: Font = .body,
        disabled: Bool = false,
        lineColor: Color = .accentColor,
        axis: Axis = .horizontal
    ) {
        self.titleKey = titleKey
        self.text = text
        self.textFieldStyle = RoundedTextFieldStyle(lineColor: lineColor, disabled: disabled, font: font)
        self.prompt = Text(titleKey).foregroundStyle(.gray)
        self.axis = axis
    }
    
    var body: some View {
        TextField(titleKey, text: text, prompt: prompt, axis: axis)
            .textFieldStyle(textFieldStyle)
    }
    
    func secured() -> some View {
        SecureField(titleKey, text: text, prompt: prompt)
            .textFieldStyle(textFieldStyle)
    }
}

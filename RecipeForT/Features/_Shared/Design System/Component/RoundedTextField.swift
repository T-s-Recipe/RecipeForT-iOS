//
//  RoundedTextField.swift
//  RecipeForT
//
//  Created by Swain Yun on 6/20/25.
//

import SwiftUI

struct RoundedTextField: View {
    @Binding var text: String
    
    private var isFocused: FocusState<Bool>.Binding
    private let titleKey: String
    
    init(
        _ prompt: String,
        text: Binding<String>,
        _ isFocused: FocusState<Bool>.Binding
    ) {
        self.titleKey = prompt
        self._text = text
        self.isFocused = isFocused
    }
    
    var body: some View {
        HStack {
            textFieldArea
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
            
            if text.isEmpty == false {
                removeButton
            }
        }
        .padding(12)
        .frame(height: 44)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(.clear)
                .strokeBorder(isFocused.wrappedValue ? .black : .gray)
        )
    }
    
    private var textFieldArea: some View {
        TextField(titleKey, text: $text)
            .focused(isFocused)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
    }
    
    private var removeButton: some View {
        Button {
            text.removeAll()
            isFocused.wrappedValue = false
        } label: {
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.gray)
        }
    }
}

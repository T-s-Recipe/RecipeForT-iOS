//
//  RoundedTextField.swift
//  RecipeForT
//
//  Created by Swain Yun on 6/20/25.
//

import SwiftUI

struct RoundedTextField: View {
    enum State {
        case onError
        case normal
        
        var strokeBorderColor: Color {
            switch self {
            case .onError: .hex(0xE51220)
            case .normal: .black
            }
        }
    }
    
    @Binding var text: String
    private let state: State
    private var isFocused: FocusState<Bool>.Binding
    private let titleKey: String
    
    init(
        _ prompt: String,
        text: Binding<String>,
        _ isFocused: FocusState<Bool>.Binding,
        state: State = .normal
    ) {
        self.titleKey = prompt
        self._text = text
        self.isFocused = isFocused
        self.state = state
    }
    
    var body: some View {
        HStack {
            textFieldArea
                .padding(.vertical, 8)
                .padding(.trailing, 12)
            
            if text.isEmpty == false {
                removeButton
            }
        }
        .padding(12)
        .frame(height: 44)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(.clear)
                .strokeBorder(currentBorderColor)
        )
    }
    
    private var currentBorderColor: Color {
        if state == .onError { return state.strokeBorderColor }
        return isFocused.wrappedValue ? state.strokeBorderColor : .gray
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

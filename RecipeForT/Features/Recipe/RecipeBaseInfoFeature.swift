//
//  RecipeBaseInfoFeature.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/12/25.
//

import SwiftUI

struct RecipeBaseInfoFeature {
    enum TextFieldType {
        case title, servings, cost, time, notes
        
        var next: TextFieldType? {
            switch self {
            case .title:
                return .servings
            case .servings:
                return .cost
            case .cost:
                return .time
            case .time:
                return .notes
            case .notes:
                return nil
            }
        }
    }
    
    @Bindable var state: EditRecipeState
    @FocusState private var focused: TextFieldType?
}

extension RecipeBaseInfoFeature: ViewFeature {
    enum UIEvent {
        
    }
    
    func notify(_ event: UIEvent) {
        
    }
}

extension RecipeBaseInfoFeature: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Base Information")
                .font(.title3.bold())
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            
            Text("Picture *")
            
            ImagePickerFeature(selectedImageItem: $state.image)
            
            Text("Title *")
            
            textField("Title of the recipe", text: $state.title, equals: .title)
            
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Servings *")
                    
                    textField("How many servings?", text: $state.servings, equals: .servings, isDisabled: state.isServingsDisabled)
                    
                    HStack(spacing: 8) {
                        CheckboxButton(isOn: $state.isServingsDisabled)
                        
                        Text("Not sure")
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Cost ($)")
                    
                    textField("Cooking cost", text: $state.cost, equals: .cost, isDisabled: state.isCostDisabled)
                    
                    HStack(spacing: 8) {
                        CheckboxButton(isOn: $state.isCostDisabled)
                        
                        Text("Not sure")
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Duration (min)")
                    
                    textField("Total cooking time", text: $state.time, equals: .time, isDisabled: state.isTimeDisabled)
                    
                    HStack(spacing: 8) {
                        CheckboxButton(isOn: $state.isTimeDisabled)
                        
                        Text("Not sure")
                    }
                }
            }
            
            Text("Recipe Notes")
            
            textField("Add notes or tips for this recipe", text: $state.notes, equals: .notes)
                .lineLimit(10)
        }
        .padding()
    }
    
    @ViewBuilder private func textField(
        _ prompt: String,
        text: Binding<String>,
        equals: TextFieldType,
        isDisabled: Bool = false
    ) -> some View {
        TextField(prompt, text: text, axis: .vertical)
            .focused($focused, equals: equals)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .foregroundStyle(isDisabled ? .gray : .primary)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(isDisabled ? .gray.opacity(0.3) : .clear)
                    .strokeBorder(focused == equals ? .black : .gray)
            )
            .onSubmit { focused = equals.next }
            .disabled(isDisabled)
    }
}

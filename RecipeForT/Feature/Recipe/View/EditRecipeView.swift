//
//  EditRecipeView.swift
//  RecipeForT
//
//  Created by Swain Yun on 6/23/25.
//

import SwiftUI

struct EditRecipeView: View {
    var body: some View {
        ZStack {
            ScrollView(.vertical) {
                RecipeBaseInfo()
                
                thickDivider
                
                IngredientsInfo()
                
                thickDivider
            }
        }
    }
    
    private var thickDivider: some View {
        Rectangle()
            .frame(height: 10)
            .foregroundStyle(.gray.opacity(0.3))
    }
}

// MARK: - Subviews
extension EditRecipeView {
    struct RecipeBaseInfo: View {
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
        
        @FocusState private var focused: TextFieldType?
        @State private var title: String = String()
        @State private var servings: String = String()
        @State private var cost: String = String()
        @State private var time: String = String()
        @State private var notes: String = String()
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("Base Information")
                    .font(.title3.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                
                Text("Picture *")
                
                Image(systemName: "camera.fill")
                    .resizable()
                    .frame(width: 28, height: 28)
                    .padding(16)
                    .foregroundStyle(.gray)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.clear)
                            .strokeBorder(.gray)
                    )
                
                Text("Title *")
                
                textField("Title of the recipe", text: $title, equals: .title)
                
                HStack(spacing: 12) {
                    VStack(alignment: .leading) {
                        Text("Servings")
                        
                        textField("How many servings?", text: $servings, equals: .servings)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Cost")
                        
                        textField("Cooking cost", text: $cost, equals: .cost)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Time(min)")
                        
                        textField("Total cooking time", text: $time, equals: .time)
                    }
                }
                
                Text("Recipe Notes")
                
                textField("Add notes or tips for this recipe", text: $notes, equals: .notes)
            }
            .padding()
        }
        
        @ViewBuilder private func textField(
            _ prompt: String,
            text: Binding<String>,
            equals: TextFieldType
        ) -> some View {
            TextField(prompt, text: text)
                .focused($focused, equals: equals)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.clear)
                        .strokeBorder(focused == equals ? .black : .gray)
                )
                .onSubmit { focused = equals.next }
        }
    }
    
    struct IngredientsInfo: View {
        @State private var ingredients: [Ingredient] = []
        
        var body: some View {
            VStack(spacing: 12) {
                Text("Ingredients")
                    .font(.title3.bold())
                
                Text("Select one of the following measurement units.")
                    .foregroundStyle(.gray)
                
                // 재료목록
                ScrollView(.horizontal) {
                    LazyHStack {
                        // 하나씩 추가하는 재료목록
                    }
                }
                
                Button {
                    
                } label: {
                    HStack {
                        Spacer()
                        
                        Image(systemName: "plus.circle")
                        
                        Text("Add ingredient")
                        
                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.clear)
                            .strokeBorder(.gray)
                    )
                }
                .tint(.black)
            }
            .padding()
        }
    }
}

#Preview {
    EditRecipeView()
}

//
//  EditRecipeView.swift
//  RecipeForT
//
//  Created by Swain Yun on 6/23/25.
//

import SwiftUI

struct EditRecipeView: View {
    @EnvironmentObject var router: Router
    @State private var editor: RecipeEditor
    
    init(recipe: Recipe?) {
        self.editor = RecipeEditor(recipe: recipe)
    }
    
    var body: some View {
        ZStack {
            VStack {
                navigationHeader
                
                ScrollView(.vertical) {
                    @Bindable var editor = editor
                    
                    LazyVStack {
                        RecipeBaseInfo(
                            title: $editor.titleText,
                            servings: $editor.servingsText,
                            cost: $editor.costText,
                            time: $editor.timeText,
                            notes: $editor.notesText
                        )
                        
                        thickDivider
                        
                        IngredientsInfo(editor: editor)
                        
                        thickDivider
                    }
                }
            }
        }
    }
    
    @ViewBuilder private var navigationHeader: some View {
        HStack {
            Button {
                router.dismiss()
            } label: {
                Image(systemName: "xmark")
            }
            .tint(.black)
            
            Spacer()
            
            Text("Recipe")
            
            Spacer()
            
            Button {
                // TODO: 레시피 등록 기능
            } label: {
                Text("등록")
            }
            .tint(.black)
        }
        .padding()
        
        Divider()
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
        @Binding private var title: String
        @Binding private var servings: String
        @Binding private var cost: String
        @Binding private var time: String
        @Binding private var notes: String
        
        init(
            title: Binding<String>,
            servings: Binding<String>,
            cost: Binding<String>,
            time: Binding<String>,
            notes: Binding<String>
        ) {
            self._title = title
            self._servings = servings
            self._cost = cost
            self._time = time
            self._notes = notes
        }
        
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
        @Bindable var editor: RecipeEditor
        
        var body: some View {
            VStack(spacing: 12) {
                Text("Ingredients")
                    .font(.title3.bold())
                    .padding(.top, 16)
                
                HStack(spacing: 12) {
                    Button {
                        editor.decreaseServingsCount()
                    } label: {
                        Image(systemName: "minus")
                    }
                    .background(
                        Circle()
                            .fill(.gray.opacity(0.3))
                            .frame(width: 24, height: 24)
                    )
                    .tint(.black)
                    
                    Text("\(editor.servings) \(editor.servings > 1 ? "Servings" : "Serving")")
                        .monospacedDigit()

                    Button {
                        editor.increaseServingsCount()
                    } label: {
                        Image(systemName: "plus")
                    }
                    .background(
                        Circle()
                            .fill(.gray.opacity(0.3))
                            .frame(width: 24, height: 24)
                    )
                    .tint(.black)
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyVStack {
                        ForEach($editor.ingredients) { ingredient in
                            VStack {
                                IngredientRow(ingredient: ingredient) {
                                    editor.removeIngredient(ingredient.wrappedValue)
                                }
                                
                                if editor.ingredients.count > 1 && editor.ingredients.last?.id != ingredient.id {
                                    Divider()
                                        .padding(.vertical)
                                }
                            }
                            
                        }
                    }
                }
                .contentMargins(16)
                
                HStack {
                    Button {
                        editor.addIngredient()
                    } label: {
                        Label("Add Ingredient", systemImage: "plus.circle")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(.gray)
                            )
                    }
                    .tint(.white)
                    .padding([.horizontal, .bottom])
                }
            }
        }
    }
    
    struct IngredientRow: View {
        @Binding var ingredient: Ingredient
        @State private var formatter = DecimalFormatter()
        
        private let maxNameLength: Int = 20
        
        let onDelete: () -> Void
        
        var body: some View {
            HStack(spacing: 12) {
                Button {
                    onDelete()
                } label: {
                    Image(systemName: "minus.circle")
                }
                .tint(.gray)
                
                VStack(alignment: .leading) {
                    Text("Name")
                    
                    TextField("Ingredient name", text: $ingredient.name)
                        .padding(12)
                        .frame(height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(.clear)
                                .strokeBorder(.gray)
                        )
                }
                
                Group {
                    decimalTextField("Qty", value: $ingredient.units[.quantity])
                    decimalTextField("Tbsp", value: $ingredient.units[.tablespoon])
                    decimalTextField("Tsp", value: $ingredient.units[.teaspoon])
                    decimalTextField("Cup", value: $ingredient.units[.cup])
                    decimalTextField("g", value: $ingredient.units[.gram])
                    decimalTextField("ml", value: $ingredient.units[.milliliters])
                    decimalTextField("oz", value: $ingredient.units[.ounce])
                }
            }
        }
        
        @ViewBuilder private func decimalTextField(_ label: any StringProtocol, value: Binding<Decimal?>) -> some View {
            VStack {
                Text(label)
                
                TextField("0", value: value, formatter: formatter)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .padding(12)
                    .frame(width: 80, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.clear)
                            .strokeBorder(.gray)
                    )
            }
        }
        
        private func onNameChange(_ : String, after: String) {
            guard after.count > maxNameLength else { return }
            ingredient.name = String(after.prefix(maxNameLength))
        }
    }
}

#Preview {
    EditRecipeView(recipe: PreviewHelper.shared.mockRecipe)
        .environmentObject(Router())
}

/*
 
 */

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
    @State private var isFullScreenCoverPresented: Bool = false
    
    init(recipe: Recipe?) {
        self.editor = RecipeEditor(recipe: recipe)
    }
    
    var body: some View {
        VStack {
            navigationHeader
            
            ScrollView(.vertical) {
                LazyVStack {
                    RecipeBaseInfo(editor: editor)
                    
                    thickDivider
                    
                    IngredientsInfo(editor: editor)
                    
                    thickDivider
                }
            }
        }
        .fullScreenCover(isPresented: $isFullScreenCoverPresented) {
            MustReadSheet()
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
            
            HStack(spacing: 4) {
                Text("Recipe")
                
                Button {
                    isFullScreenCoverPresented.toggle()
                } label: {
                    Image(systemName: "info.circle")
                }
                .tint(.black)
            }
            
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
        @Bindable var editor: RecipeEditor
        
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
                
                textField("Title of the recipe", text: $editor.titleText, equals: .title)
                
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Servings *")
                        
                        textField("How many servings?", text: $editor.servingsText, equals: .servings, isDisabled: editor.isServingsTextFieldDisabled)
                        
                        HStack(spacing: 8) {
                            CheckboxButton(isOn: $editor.isServingsTextFieldDisabled)
                            
                            Text("Not sure")
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Cost ($)")
                        
                        textField("Cooking cost", text: $editor.costText, equals: .cost, isDisabled: editor.isCostTextFieldDisabled)
                        
                        HStack(spacing: 8) {
                            CheckboxButton(isOn: $editor.isCostTextFieldDisabled)
                            
                            Text("Not sure")
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Duration (min)")
                        
                        textField("Total cooking time", text: $editor.timeText, equals: .time, isDisabled: editor.isTimeTextFieldDisabled)
                        
                        HStack(spacing: 8) {
                            CheckboxButton(isOn: $editor.isTimeTextFieldDisabled)
                            
                            Text("Not sure")
                        }
                    }
                }
                
                Text("Recipe Notes")
                
                textField("Add notes or tips for this recipe", text: $editor.notesText, equals: .notes)
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
                        ForEach($editor.ingredients) { $ingredient in
                            VStack {
                                IngredientRow(ingredient: $ingredient) {
                                    editor.removeIngredient(with: ingredient.id)
                                } onMoveUp: {
                                    editor.moveIngredientUp(with: ingredient.id)
                                } onMoveDown: {
                                    editor.moveIngredientDown(with: ingredient.id)
                                }

                                if ingredient.id != editor.ingredients.last?.id {
                                    Divider().padding(.vertical, 8)
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
        
        let onRemove: () -> Void
        let onMoveUp: () -> Void
        let onMoveDown: () -> Void
        
        var body: some View {
            HStack(spacing: 12) {
                VStack(spacing: 0) {
                    Button {
                        onMoveUp()
                    } label: {
                        Image(systemName: "chevron.up")
                            .padding(.horizontal, 7)
                            .padding(.vertical, 9)
                            .background(
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(.clear)
                                    .strokeBorder(.gray)
                            )
                    }
                    .tint(.gray)
                    
                    Button {
                        onMoveDown()
                    } label: {
                        Image(systemName: "chevron.down")
                            .padding(.horizontal, 7)
                            .padding(.vertical, 9)
                            .background(
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(.clear)
                                    .strokeBorder(.gray)
                            )
                    }
                    .tint(.gray)
                }
                
                Button {
                    onRemove()
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

// MARK: - Sheet
extension EditRecipeView {
    struct MustReadSheet: View {
        @Environment(\.dismiss) private var dismiss
        
        var body: some View {
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .tint(.black)
                    
                    Spacer()
                    
                    Text("Must read")
                    
                    Spacer()
                }
                .padding()
                
                Divider()
                
                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Sauce mixing order")
                            .font(.headline)
                        
                        Text("When writing out detailed recipe steps, please follow this order:")
                        Text("List the ingredients starting with those that don't stick to the spoon, followed by those that do. (e.g. sugar, salt -> honey, soy sauce")
                        
                        Text("Measurement units")
                            .font(.headline)
                        
                        Text("1T: 1 tablespoon")
                        Text("1t: 1 teaspoon")
                        
                        Text("Recipe")
                            .font(.headline)
                        
                        Text("When writing a recipe, avoid writing long sentences. Break them down into shorter steps as much as possible.")
                    }
                    .padding(16)
                }
            }
            .presentationDetents([.fraction(0.9999)])
        }
    }
}

#Preview {
    EditRecipeView(recipe: PreviewHelper.shared.mockRecipe)
        .environmentObject(Router())
}

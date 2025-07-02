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
                            title: $editor.title,
                            servings: $editor.servings,
                            cost: $editor.cost,
                            time: $editor.time,
                            notes: $editor.notes
                        )
                        
                        thickDivider
                        
                        IngredientsInfo(ingredients: $editor.ingredients)
                        
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
        @Binding var ingredients: [Ingredient]
        
        init(
            ingredients: Binding<[Ingredient]>
        ) {
            self._ingredients = ingredients
        }
        
        var body: some View {
            VStack(spacing: 12) {
                Text("Ingredients")
                    .font(.title3.bold())
                
                Text("Select one of the following measurement units.")
                    .foregroundStyle(.gray)
                
                ForEach(0..<ingredients.count, id: \.self) { index in
                    IngredientCell(ingredient: $ingredients[index]) {
                        ingredients.remove(at: index)
                    }
                }
                
                Button {
                    ingredients.append(Ingredient(name: "", units: []))
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
    
    struct IngredientCell: View {
        @Binding var ingredient: Ingredient
        @State private var isExpanded: Bool = false
        @State private var ingredientName: String = String()
        @State private var selectedMeasurementUnitIndex: Int = .zero
        @State private var ammount: String = String()
        @State private var selectedMeasurementUnit: MeasurementUnit = .quantity
        
        let removeAction: () -> Void
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                TextField("Ingredient name", text: $ingredientName)
                
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach(0..<ingredient.units.count, id: \.self) { index in
                            Button {
                                selectMeasurementUnit(index)
                            } label: {
                                Text("\(ingredient.units[index].ammount) " + ingredient.units[index].measurement.short)
                                    .monospacedDigit()
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 8)
                            }
                            .id(index)
                        }
                        
                        Button {
                            let newIngredientUnit = IngredientUnit(measurement: .quantity, ammount: .zero)
                            ingredient.units.append(newIngredientUnit)
                            selectMeasurementUnit(ingredient.units.count - 1)
                        } label: {
                            Image(systemName: "plus.circle")
                        }
                    }
                }
                .scrollIndicators(.never)
                .defaultScrollAnchor(.trailing, for: .initialOffset)
                
                if isExpanded {
                    VStack {
                        HStack {
                            TextField("Ammount", text: $ammount)
                                .keyboardType(.decimalPad)
                            
                            Picker("Select measurement unit", selection: $selectedMeasurementUnit) {
                                ForEach(MeasurementUnit.allCases, id: \.self) { measurementUnit in
                                    Button(measurementUnit.short) {
                                        selectedMeasurementUnit = measurementUnit
                                    }
                                }
                            }
                            .pickerStyle(.menu)
                            
                            Button {
                                let newIngredientUnit = IngredientUnit(measurement: selectedMeasurementUnit, ammount: Double(ammount) ?? .zero)
                                ingredient.units[selectedMeasurementUnitIndex] = newIngredientUnit
                                isExpanded = false
                            } label: {
                                Label("Done", systemImage: "checkmark")
                            }
                        }
                        
                        Button {
                            removeAction()
                        } label: {
                            HStack {
                                Spacer()
                                
                                Image(systemName: "minus.circle")
                                
                                Text("Delete ingredient")
                                
                                Spacer()
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(.clear)
                                    .strokeBorder(.gray)
                            )
                        }
                        .tint(.red)
                    }
                }
            }
            .overlay(alignment: .bottom) {
                Divider()
            }
        }
        
        private func selectMeasurementUnit(_ index: Int) {
            ammount = String(ingredient.units[index].ammount)
            selectedMeasurementUnit = ingredient.units[index].measurement
            selectedMeasurementUnitIndex = index
            isExpanded = true
        }
    }
}

#Preview {
    EditRecipeView(recipe: nil)
        .environmentObject(Router())
}

//
//  RecipeIngredientsInfoFeature.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/12/25.
//

import SwiftUI

@MainActor
struct RecipeIngredientsInfoFeature {
    @Bindable var state: EditRecipeState
}

extension RecipeIngredientsInfoFeature: ViewFeature {
    enum UIEvent {
        case addIngredient
        case removeIngredient(id: UUID)
        case moveIngredientUp(id: UUID)
        case moveIngredientDown(id: UUID)
        case onIngredientChanged(Ingredient)
        case addSource
        case removeSource(id: UUID)
        case moveSourceUp(id: UUID)
        case moveSourceDown(id: UUID)
        case onSourceChanged(Ingredient)
    }
    
    func notify(_ event: UIEvent) {
        switch event {
        case .addIngredient:
            state.ingredients.append(.init(name: "", units: .init()))
        case .removeIngredient(let id):
            removeIngredient(id: id)
        case .moveIngredientUp(let id):
            onIngredientMoveUp(id: id)
        case .moveIngredientDown(let id):
            onIngredientMoveDown(id: id)
        case .onIngredientChanged(let ingredient):
            onIngredientChanged(ingredient)
        case .addSource:
            state.sources.append(.init(name: "", units: .init()))
        case .removeSource(let id):
            removeSource(id: id)
        case .moveSourceUp(let id):
            onSourceMoveUp(id: id)
        case .moveSourceDown(let id):
            onSourceMoveDown(id: id)
        case .onSourceChanged(let ingredient):
            onSourcechanged(ingredient)
        }
    }
}

extension RecipeIngredientsInfoFeature: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Ingredients")
                .font(.title3.bold())
                .padding(.top, 16)
            
            // MARK: - Basic ingredients
            Section {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyVStack {
                        ForEach($state.ingredients) { $ingredient in
                            VStack {
                                IngredientRow(ingredient: $ingredient) {
                                    notify(.removeIngredient(id: ingredient.id))
                                } onMoveUp: {
                                    notify(.moveIngredientUp(id: ingredient.id))
                                } onMoveDown: {
                                    notify(.moveIngredientDown(id: ingredient.id))
                                }

                                if ingredient.id != state.ingredients.last?.id {
                                    Divider().padding(.vertical, 8)
                                }
                            }
                        }
                    }
                }
                .contentMargins(16)
            } header: {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Basic ingredients")
                        .font(.headline)
                    
                    Rectangle()
                        .frame(height: 2)
                }
                .padding([.top, .horizontal])
            }
            
            HStack {
                Button {
                    notify(.addIngredient)
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
            
            // MARK: - Sources area
            Section {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyVStack {
                        ForEach($state.sources) { $source in
                            VStack {
                                IngredientRow(ingredient: $source) {
                                    notify(.removeSource(id: source.id))
                                } onMoveUp: {
                                    notify(.moveSourceUp(id: source.id))
                                } onMoveDown: {
                                    notify(.moveSourceDown(id: source.id))
                                }

                                if source.id != state.sources.last?.id {
                                    Divider().padding(.vertical, 8)
                                }
                            }
                        }
                    }
                }
                .contentMargins(16)
            } header: {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Source")
                        .font(.headline)
                    
                    Rectangle()
                        .frame(height: 2)
                }
                .padding([.top, .horizontal])
            }
            
            HStack {
                Button {
                    notify(.addSource)
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
    
    private func removeIngredient(id: UUID) {
        state.ingredients.removeAll(where: { $0.id == id })
    }
    
    private func onIngredientMoveUp(id: UUID) {
        if let index = state.ingredients.firstIndex(where: { $0.id == id }),
           index > 0 {
            state.ingredients.swapAt(index, index - 1)
        }
    }
    
    private func onIngredientMoveDown(id: UUID) {
        if let index = state.ingredients.firstIndex(where: { $0.id == id }),
           index < state.ingredients.count - 1 {
            state.ingredients.swapAt(index, index + 1)
        }
    }
    
    private func onIngredientChanged(_ ingredient: Ingredient) {
        guard let index = state.ingredients.firstIndex(where: { $0.id == ingredient.id }) else { return }
        state.ingredients[index] = ingredient
    }
    
    private func removeSource(id: UUID) {
        state.sources.removeAll { $0.id == id }
    }
    
    private func onSourceMoveUp(id: UUID) {
        if let index = state.sources.firstIndex(where: { $0.id == id }),
           index > 0 {
            state.sources.swapAt(index, index - 1)
        }
    }
    
    private func onSourceMoveDown(id: UUID) {
        if let index = state.sources.firstIndex(where: { $0.id == id }),
           index < state.sources.count - 1 {
            state.sources.swapAt(index, index + 1)
        }
    }
    
    private func onSourcechanged(_ source: Ingredient) {
        guard let index = state.sources.firstIndex(where: { $0.id == source.id }) else { return }
        state.sources[index] = source
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
                decimalTextField("Tbsp", value: $ingredient.units[.tablespoon])
                decimalTextField("Tsp", value: $ingredient.units[.teaspoon])
                decimalTextField("Cup", value: $ingredient.units[.cup])
                decimalTextField("g", value: $ingredient.units[.gram])
                decimalTextField("ml", value: $ingredient.units[.milliliters])
                decimalTextField("oz", value: $ingredient.units[.ounce])
                decimalTextField("Qty", value: $ingredient.units[.quantity])
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

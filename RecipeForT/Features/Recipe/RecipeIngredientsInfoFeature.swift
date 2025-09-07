//
//  RecipeIngredientsInfoFeature.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/12/25.
//

import SwiftUI
import ComposableArchitecture
import UniformTypeIdentifiers

@Reducer
struct RecipeIngredientsInfoFeature {
    @ObservableState
    struct State: Equatable {
        var ingredients: IdentifiedArrayOf<IngredientRowFeature.State> = []
        var sources: IdentifiedArrayOf<IngredientRowFeature.State> = []
        
        init(recipe: Recipe?) {
            let ingredients = (recipe?.ingredients ?? []).map { IngredientRowFeature.State(id: $0.id, ingredient: $0) }
            let sources = (recipe?.sources ?? []).map { IngredientRowFeature.State(id: $0.id, ingredient: $0) }
            self.ingredients = IdentifiedArray(uniqueElements: ingredients)
            self.sources = IdentifiedArray(uniqueElements: sources)
        }
    }
    
    enum Action {
        @CasePathable
        enum ViewAction {
            case addIngredientButtonTapped
            case addSourceButtonTapped
            case moveIngredient(id: UUID, destinationID: UUID)
            case moveSource(id: UUID, destinationID: UUID)
        }
        
        case view(ViewAction)
        case ingredient(IdentifiedAction<IngredientRowFeature.State.ID, IngredientRowFeature.Action>)
        case source(IdentifiedAction<IngredientRowFeature.State.ID, IngredientRowFeature.Action>)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(.addIngredientButtonTapped):
                let newIngredient = Ingredient(name: "", units: .init())
                state.ingredients.append(.init(id: newIngredient.id, ingredient: newIngredient))
                return .none
                
            case .view(.addSourceButtonTapped):
                let newSource = Ingredient(name: "", units: .init())
                state.sources.append(.init(id: newSource.id, ingredient: newSource))
                return .none
                
            case let .view(.moveIngredient(id, destinationID)):
                guard let index = state.ingredients.index(id: id),
                      let destinationIndex = state.ingredients.index(id: destinationID)
                else { return .none }
                
                let item = state.ingredients.remove(at: index)
                state.ingredients.insert(item, at: destinationIndex)
                return .none
                
            case let .view(.moveSource(id, destinationID)):
                guard let index = state.sources.index(id: id),
                      let destinationIndex = state.sources.index(id: destinationID)
                else { return .none }
                let item = state.sources.remove(at: index)
                state.sources.insert(item, at: destinationIndex)
                return .none
                
            case let .ingredient(.element(id, .delegate(.removeButtonTapped))):
                state.ingredients.remove(id: id)
                return .none
                
            case let .ingredient(.element(id, .delegate(.moveUpButtonTapped))):
                guard let index = state.ingredients.index(id: id),
                      index > 0
                else { return .none }
                state.ingredients.swapAt(index, index - 1)
                return .none
                
            case let .ingredient(.element(id, .delegate(.moveDownButtonTapped))):
                guard let index = state.ingredients.index(id: id),
                      index < state.ingredients.count - 1
                else { return .none }
                state.ingredients.swapAt(index, index + 1)
                return .none
                
            case let .source(.element(id, .delegate(.removeButtonTapped))):
                state.sources.remove(id: id)
                return .none
                
            case let .source(.element(id, .delegate(.moveUpButtonTapped))):
                guard let index = state.sources.index(id: id),
                      index > 0
                else { return .none }
                state.sources.swapAt(index, index - 1)
                return .none
                
            case let .source(.element(id, .delegate(.moveDownButtonTapped))):
                guard let index = state.sources.index(id: id),
                      index < state.sources.count - 1
                else { return .none }
                state.sources.swapAt(index, index + 1)
                return .none
                
            case .ingredient, .source:
                return .none
            }
        }
        .forEach(\.ingredients, action: \.ingredient) { IngredientRowFeature() }
        .forEach(\.sources, action: \.source) { IngredientRowFeature() }
    }
}

struct RecipeIngredientsInfoView: View {
    @Bindable var store: StoreOf<RecipeIngredientsInfoFeature>
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Ingredients")
                .font(.title3.bold())
                .padding(.top, 16)
            
            // MARK: - Basic ingredients
            Section {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyVStack {
                        ForEachStore(store.scope(state: \.ingredients, action: \.ingredient)) { ingredientStore in
                            VStack {
                                IngredientRowView(store: ingredientStore)
                                    .dropDestination(for: IngredientRowFeature.State.self) { items, location in
                                        guard let droppedItem = items.first else { return false }
                                        store.send(.view(.moveIngredient(id: droppedItem.id, destinationID: ingredientStore.id)))
                                        return true
                                    }
                                    .draggable(ingredientStore.state)
                                
                                if ingredientStore.id != store.ingredients.last?.id {
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
                    store.send(.view(.addIngredientButtonTapped))
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
                        ForEachStore(store.scope(state: \.sources, action: \.source)) { sourceStore in
                            IngredientRowView(store: sourceStore)
                                .dropDestination(for: IngredientRowFeature.State.self) { items, location in
                                    guard let droppedItem = items.first else { return false }
                                    store.send(.view(.moveSource(id: droppedItem.id, destinationID: sourceStore.id)))
                                    return true
                                }
                                .draggable(sourceStore.state)
                            
                            if sourceStore.id != store.sources.last?.id {
                                Divider().padding(.vertical, 8)
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
                    store.send(.view(.addSourceButtonTapped))
                } label: {
                    Label("Add Source", systemImage: "plus.circle")
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

@Reducer
struct IngredientRowFeature {
    let maxNameLength: Int = 20
    
    @ObservableState
    struct State: Equatable, Identifiable, Codable, Transferable {
        let id: UUID
        var ingredient: Ingredient
        
        static var transferRepresentation: some TransferRepresentation {
            CodableRepresentation(contentType: .ingredient)
        }
    }
    
    enum Action {
        @CasePathable
        enum ViewAction {
            case ingredientNameChanged(String)
            case setUnit(MeasurementUnit, Decimal?)
        }
        
        @CasePathable
        enum Delegate {
            case removeButtonTapped
            case moveUpButtonTapped
            case moveDownButtonTapped
        }
        
        case view(ViewAction)
        case delegate(Delegate)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(.ingredientNameChanged(let name)):
                guard name.count > maxNameLength else { return .none }
                state.ingredient.name = name
                return .none
                
            case let .view(.setUnit(unit, value)):
                state.ingredient.units[unit] = value
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
}

extension UTType {
    static let ingredient = UTType(exportedAs: "ingredient")
}

struct IngredientRowView: View {
    @Bindable var store: StoreOf<IngredientRowFeature>
    @State private var formatter = DecimalFormatter()
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(spacing: 0) {
                Button {
                    store.send(.delegate(.moveUpButtonTapped))
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
                    store.send(.delegate(.moveDownButtonTapped))
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
                store.send(.delegate(.removeButtonTapped))
            } label: {
                Image(systemName: "minus.circle")
            }
            .tint(.gray)
            
            VStack(alignment: .leading) {
                Text("Name")
                
                TextField("Ingredient name", text: $store.ingredient.name.sending(\.view.ingredientNameChanged))
                    .padding(12)
                    .frame(height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.clear)
                            .strokeBorder(.gray)
                    )
            }
            
            Group {
                decimalTextField("Tbsp", unit: .tablespoon)
                decimalTextField("Tsp", unit: .teaspoon)
                decimalTextField("Cup", unit: .cup)
                decimalTextField("g", unit: .gram)
                decimalTextField("ml", unit: .milliliters)
                decimalTextField("oz", unit: .ounce)
                decimalTextField("Qty", unit: .quantity)
            }
        }
    }
    
    @ViewBuilder private func decimalTextField(_ label: any StringProtocol, unit: MeasurementUnit) -> some View {
        VStack {
            Text(label)
            
            TextField(
                "0",
                value: Binding(
                    get: { store.ingredient.units[unit] },
                    set: { store.send(.view(.setUnit(unit, $0))) }
                ),
                formatter: formatter
            )
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
}

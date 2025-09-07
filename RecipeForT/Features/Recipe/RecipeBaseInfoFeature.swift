//
//  RecipeBaseInfoFeature.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/12/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct RecipeBaseInfoFeature {
    enum TextFieldType: Hashable {
        case title, servings, cost, time, notes
        
        var next: TextFieldType? {
            switch self {
            case .title: .servings
            case .servings: .cost
            case .cost: .time
            case .time: .notes
            case .notes: nil
            }
        }
    }
    
    @ObservableState
    struct State: Equatable {
        var imagePicker = ImagePickerFeature.State()
        var selectedImage: ImageItem?
        var title: String = String()
        var servings: String = String()
        var cost: String = String()
        var time: String = String()
        var notes: String = String()
        var isServingsDisabled: Bool = false
        var isCostDisabled: Bool = false
        var isTimeDisabled: Bool = false
        var focusedField: TextFieldType?
        
        init(recipe: Recipe?) {
            title = recipe?.name ?? ""
            servings = "\(recipe?.servingsCount ?? .zero)"
            cost = "\(recipe?.cost ?? .zero)"
            time = "\(recipe?.cookingTime ?? .zero)"
            notes = recipe?.description ?? ""
        }
    }
    
    enum Action {
        @CasePathable
        enum ViewAction {
            case focusChanged(TextFieldType?)
            case submitTextField
            case setTitle(String)
            case setServings(String)
            case setCost(String)
            case setTime(String)
            case setNotes(String)
            case toggleServingsDisabled(Bool)
            case toggleCostDisabled(Bool)
            case toggleTimeDisabled(Bool)
        }
        
        case view(ViewAction)
        case imagePicker(ImagePickerFeature.Action)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.imagePicker, action: \.imagePicker) { ImagePickerFeature() }
        
        Reduce { state, action in
            switch action {
            case .view(.focusChanged(let field)):
                state.focusedField = field
                return .none
                
            case .view(.submitTextField):
                state.focusedField = state.focusedField?.next
                return .none
                
            case .view(.setTitle(let title)):
                state.title = title
                return .none
                
            case .view(.setServings(let servings)):
                state.servings = servings
                return .none
                
            case .view(.setCost(let cost)):
                state.cost = cost
                return .none
                
            case .view(.setTime(let time)):
                state.time = time
                return .none
                
            case .view(.setNotes(let notes)):
                state.notes = notes
                return .none
                
            case .view(.toggleServingsDisabled(let isDisabled)):
                state.isServingsDisabled = isDisabled
                if isDisabled { state.servings.removeAll() }
                return .none
                
            case .view(.toggleCostDisabled(let isDisabled)):
                state.isCostDisabled = isDisabled
                if isDisabled { state.cost.removeAll() }
                return .none
                
            case .view(.toggleTimeDisabled(let isDisabled)):
                state.isTimeDisabled = isDisabled
                if isDisabled { state.time.removeAll() }
                return .none
                
            case .imagePicker(.delegate(.didSelectImage(let imageItem))):
                state.selectedImage = imageItem
                return .none
                
            case .imagePicker:
                return .none
            }
        }
    }
}

struct RecipeBaseInfoView: View {
    @Bindable var store: StoreOf<RecipeBaseInfoFeature>
    @FocusState private var focusedField: RecipeBaseInfoFeature.TextFieldType?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Base Information")
                .font(.title3.bold())
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            
            Text("Picture *")
            
            ImagePickerView(store: store.scope(state: \.imagePicker, action: \.imagePicker))
            
            Text("Title *")
            
            textField("Title of the recipe", text: $store.title.sending(\.view.setTitle), equals: .title)
            
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Servings *")
                    
                    textField("How many servings?", text: $store.servings.sending(\.view.setServings), equals: .servings, isDisabled: store.isServingsDisabled)
                    
                    HStack(spacing: 8) {
                        CheckboxButton(isOn: $store.isServingsDisabled.sending(\.view.toggleServingsDisabled))
                        
                        Text("Not sure")
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Cost ($)")
                    
                    textField("Cooking cost", text: $store.cost.sending(\.view.setCost), equals: .cost, isDisabled: store.isCostDisabled)
                    
                    HStack(spacing: 8) {
                        CheckboxButton(isOn: $store.isCostDisabled.sending(\.view.toggleCostDisabled))
                        
                        Text("Not sure")
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Duration (min)")
                    textField("Total cooking time", text: $store.time.sending(\.view.setTime), equals: .time, isDisabled: store.isTimeDisabled)
                    
                    HStack(spacing: 8) {
                        CheckboxButton(isOn: $store.isTimeDisabled.sending(\.view.toggleTimeDisabled))
                        
                        Text("Not sure")
                    }
                }
            }
            
            Text("Recipe Notes")
            
            textField("Add notes or tips for this recipe", text: $store.notes.sending(\.view.setNotes), equals: .notes)
                .lineLimit(10)
        }
        .padding()
    }
    
    @ViewBuilder private func textField(
        _ prompt: String,
        text: Binding<String>,
        equals: RecipeBaseInfoFeature.TextFieldType,
        isDisabled: Bool = false
    ) -> some View {
        TextField(prompt, text: text, axis: .vertical)
            .focused($focusedField, equals: equals)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .foregroundStyle(isDisabled ? .gray : .primary)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(isDisabled ? .gray.opacity(0.3) : .clear)
                    .strokeBorder(focusedField == equals ? .black : .gray)
            )
            .onSubmit { store.send(.view(.submitTextField)) }
            .disabled(isDisabled)
    }
}

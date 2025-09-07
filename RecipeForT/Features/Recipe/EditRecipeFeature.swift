//
//  EditRecipeFeature.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/12/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct EditRecipeFeature {
    enum ScrollTarget {
        case base, ingredient, steps
    }
    
    @ObservableState
    struct State: Equatable {
        let member: Member
        var baseInfo: RecipeBaseInfoFeature.State
        var ingredientsInfo: RecipeIngredientsInfoFeature.State
        var detailedSteps: RecipeDetailedStepInfoFeature.State
        
        var isLoading: Bool = false
        var isMustReadSheetPresented: Bool = false
        var isAuthViewPresented: Bool = false
        var floaterItem: FloaterItem?
        var scrollToTarget: ScrollTarget?
        
        init(member: Member, recipe: Recipe?) {
            self.member = member
            baseInfo = .init(recipe: recipe)
            ingredientsInfo = .init(recipe: recipe)
            detailedSteps = .init(recipe: recipe)
        }
    }
    
    enum Action {
        @CasePathable
        enum ViewAction {
            case dismissButtonTapped
            case submitButtonTapped
            case setSheetPresented(Bool)
        }
        
        @CasePathable
        enum InternalAction {
            case authStateChanged(AuthenticationState)
            case setScrollToTarget(ScrollTarget?)
            case setFloaterItem(FloaterItem?)
            case uploadResponse(Result<Void, Error>)
        }
        
        @CasePathable
        enum Delegate {
            case saveCompleted
        }
        
        case view(ViewAction)
        case `internal`(InternalAction)
        case delegate(Delegate)
        
        case baseInfo(RecipeBaseInfoFeature.Action)
        case ingredientsInfo(RecipeIngredientsInfoFeature.Action)
        case detailedSteps(RecipeDetailedStepInfoFeature.Action)
    }
    
    @Dependency(\.recipeClient) var recipeClient
    @Dependency(\.authClient) var authClient
    @Dependency(\.dismiss) var dismiss
    
    var body: some Reducer<State, Action> {
        Scope(state: \.baseInfo, action: \.baseInfo) { RecipeBaseInfoFeature() }
        Scope(state: \.ingredientsInfo, action: \.ingredientsInfo) { RecipeIngredientsInfoFeature() }
        Scope(state: \.detailedSteps, action: \.detailedSteps) { RecipeDetailedStepInfoFeature() }
        
        Reduce { state, action in
            switch action {
            case .view(.dismissButtonTapped):
                return .run { _ in await dismiss() }
            case .view(.submitButtonTapped):
                guard state.baseInfo.selectedImage != nil else {
                    let item = FloaterItem(role: .warning, message: FloaterMessageNamespace.missingRequiredFields(which: "Image").message)
                    return .merge(
                        .send(.internal(.setFloaterItem(item))),
                        .send(.internal(.setScrollToTarget(.base)))
                    )
                    .animation()
                }
                
                guard state.baseInfo.title.isEmpty == false else {
                    let item = FloaterItem(role: .warning, message: FloaterMessageNamespace.missingRequiredFields(which: "Title").message)
                    return .merge(
                        .send(.internal(.setFloaterItem(item))),
                        .send(.internal(.setScrollToTarget(.base)))
                    )
                    .animation()
                }
                
                guard state.ingredientsInfo.ingredients.isEmpty == false else {
                    let item = FloaterItem(role: .warning, message: FloaterMessageNamespace.missingRequiredFields(which: "Ingredient").message)
                    return .merge(
                        .send(.internal(.setFloaterItem(item))),
                        .send(.internal(.setScrollToTarget(.ingredient)))
                    )
                    .animation()
                }
                
                guard state.detailedSteps.steps.isEmpty == false else {
                    let item = FloaterItem(role: .warning, message: FloaterMessageNamespace.missingRequiredFields(which: "Step").message)
                    return .merge(
                        .send(.internal(.setFloaterItem(item))),
                        .send(.internal(.setScrollToTarget(.steps)))
                    )
                    .animation()
                }
                
                state.isLoading = true
                return .run { [
                    id = state.member.id,
                    title = state.baseInfo.title,
                    imageItem = state.baseInfo.selectedImage,
                    servings = state.baseInfo.servings,
                    cost = state.baseInfo.cost,
                    cookingTime = state.baseInfo.time,
                    notes = state.baseInfo.notes,
                    ingredients = state.ingredientsInfo.ingredients,
                    sources = state.ingredientsInfo.sources,
                    steps = state.detailedSteps.steps
                ] send in
                    do {
                        _ = try await recipeClient.create(
                            id,
                            title,
                            imageItem,
                            Decimal(string: servings),
                            Decimal(string: cost),
                            Decimal(string: cookingTime),
                            notes,
                            ingredients.map(\.ingredient),
                            sources.map(\.ingredient),
                            steps.map {
                                CookingStep(id: $0.id, title: $0.title, detailedProcesses: $0.processes.map(\.process))
                            }
                        )
                        
                        await send(.internal(.uploadResponse(.success(()))))
                    } catch {
                        await send(.internal(.uploadResponse(.failure(error))))
                    }
                }
                
            case .view(.setSheetPresented(let isPresented)):
                state.isMustReadSheetPresented = isPresented
                return .none
                
            case .internal(.setScrollToTarget(let target)):
                state.scrollToTarget = target
                return .run { send in
                    try await Task.sleep(for: .milliseconds(500))
                    await send(.internal(.setScrollToTarget(nil)))
                }
                .animation(.smooth)
                
            case .internal(.setFloaterItem(let item)):
                state.floaterItem = item
                return .none
                
            case .internal(.uploadResponse(.success)):
                state.isLoading = false
                return .run { send in
                    await send(.delegate(.saveCompleted))
                }
                
            case .internal(.uploadResponse(.failure)):
                state.isLoading = false
                let item = FloaterItem(role: .warning, message: FloaterMessageNamespace.unknownErrorOccurred.message)
                return .send(.internal(.setFloaterItem(item)))
                
            default:
                return .none
            }
        }
    }
}

struct EditRecipeView: View {
    @Bindable var store: StoreOf<EditRecipeFeature>
    
    var body: some View {
        VStack {
            navigationHeader
            
            ScrollViewReader { proxy in
                ScrollView(.vertical) {
                    LazyVStack {
                        RecipeBaseInfoView(store: store.scope(state: \.baseInfo, action: \.baseInfo))
                            .id(EditRecipeFeature.ScrollTarget.base)
                            
                        thickDivider
                        
                        RecipeIngredientsInfoView(store: store.scope(state: \.ingredientsInfo, action: \.ingredientsInfo))
                            .id(EditRecipeFeature.ScrollTarget.ingredient)
                        
                        thickDivider
                        
                        RecipeDetailedStepInfoView(store: store.scope(state: \.detailedSteps, action: \.detailedSteps))
                            .id(EditRecipeFeature.ScrollTarget.steps)
                    }
                }
                .onChange(of: store.scrollToTarget) { _, target in
                    guard let target else { return }
                    withAnimation { proxy.scrollTo(target, anchor: .center) }
                }
                .scrollDismissesKeyboard(.immediately)
            }
        }
        .fullScreenCover(isPresented: $store.isMustReadSheetPresented.sending(\.view.setSheetPresented)) {
            MustReadSheet()
        }
        .floater($store.floaterItem.sending(\.internal.setFloaterItem))
    }
    
    @ViewBuilder private var navigationHeader: some View {
        HStack {
            Button {
                store.send(.view(.dismissButtonTapped))
            } label: {
                Image(systemName: "xmark")
            }
            .tint(.black)
            
            Spacer()
            
            HStack(spacing: 4) {
                Text("Recipe")
                
                Button {
                    store.send(.view(.setSheetPresented(true)))
                } label: {
                    Image(systemName: "info.circle")
                }
                .tint(.black)
            }
            
            Spacer()
            
            Button {
                store.send(.view(.submitButtonTapped))
            } label: {
                if store.isLoading {
                    ProgressView()
                } else {
                    Text("OK")
                }
            }
            .tint(.black)
            .disabled(store.isLoading)
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
                        .bulletPoint()
                    
                    Text("List the ingredients starting with those that don't stick to the spoon, followed by those that do. (e.g. sugar, salt -> honey, soy sauce")
                        .bulletPoint()
                    
                    Text("Measurement units")
                        .font(.headline)
                    
                    Text("1T: 1 tablespoon")
                        .bulletPoint()
                    
                    Text("1t: 1 teaspoon")
                        .bulletPoint()
                    
                    Text("Recipe")
                        .font(.headline)
                    
                    Text("When writing a recipe, avoid writing long sentences. Break them down into shorter steps as much as possible.")
                        .bulletPoint()
                }
                .padding(16)
            }
        }
    }
}

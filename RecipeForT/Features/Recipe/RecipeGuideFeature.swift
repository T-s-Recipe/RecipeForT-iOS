//
//  RecipeGuideFeature.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/12/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct RecipeGuideFeature {
    private enum CancelID { case authStateSubscription }
    
    let maxServings: Decimal = 100
    let minServings: Decimal = 1
    
    @ObservableState
    struct State: Equatable {
        var recipe: Recipe
        var authState: AuthenticationState = .loggedOut
        var currentServings: Decimal
        var originalIngredients: [Ingredient]
        var originalSources: [Ingredient]
        var floaterItem: FloaterItem?
        
        var adjustedIngredients: [Ingredient]
        var adjustedSources: [Ingredient]
        
        var isLoading = true
        @Presents var destination: Destination.State?
        
        var isAuthor: Bool {
            guard case .loggedIn(let member) = authState else { return false }
            return member.id == recipe.authorID
        }
        
        init(recipe: Recipe) {
            self.recipe = recipe
            currentServings = recipe.servingsCount ?? 1
            originalIngredients = recipe.ingredients
            originalSources = recipe.sources
            adjustedIngredients = recipe.ingredients
            adjustedSources = recipe.sources
        }
    }
    
    enum Action {
        @CasePathable
        enum ViewAction {
            case task
            case increaseServingsButtonTapped
            case decreaseServingsButtonTapped
            case editButtonTapped
            case deleteButtonTapped
            case reportButtonTapped
            case presentFloater(FloaterItem?)
        }
        
        @CasePathable
        enum InternalAction {
            case authStateChanged(AuthenticationState)
            case recipeDetailResponse(Result<Recipe, Error>)
            case deleteResponse(Result<Void, Error>)
        }
        
        @CasePathable
        enum Delegate {
            case editRecipe(Recipe)
            case reportRecipe(id: String)
            case recipeDeleted(id: String)
        }
        
        case view(ViewAction)
        case `internal`(InternalAction)
        case delegate(Delegate)
        case destination(PresentationAction<Destination.Action>)
    }
    
    @Reducer
    struct Destination {
        @ObservableState
        enum State: Equatable {
            case confirmDeletion(AlertState<Action.ConfirmDeletion>)
        }
        
        enum Action {
            enum ConfirmDeletion { case confirmButtonTapped, cancel }
            
            case confirmDeletion(ConfirmDeletion)
        }
        
        var body: some Reducer<State, Action> {
            Reduce { _, _ in .none }
        }
    }
    
    @Dependency(\.authClient) var authClient
    @Dependency(\.recipeClient) var recipeClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(.task):
                let needsFetching = state.recipe.ingredients.isEmpty || state.recipe.detailedSteps.isEmpty
                
                guard needsFetching else {
                    state.isLoading = false
                    return .run { send in
                        for await authState in authClient.authenticationState() {
                            await send(.internal(.authStateChanged(authState)))
                        }
                    }
                    .cancellable(id: CancelID.authStateSubscription)
                }
                
                state.isLoading = true
                return .merge(
                    .run(operation: { [id = state.recipe.id] send in
                        await send(.internal(.recipeDetailResponse(Result { try await recipeClient.readRecipe(id) })))
                    }),
                    .run(operation: { send in
                        for await authState in authClient.authenticationState() {
                            await send(.internal(.authStateChanged(authState)))
                        }
                    })
                    .cancellable(id: CancelID.authStateSubscription)
                )
                
            case .view(.increaseServingsButtonTapped):
                guard state.currentServings < maxServings else { return .none }
                state.currentServings = (state.currentServings + 0.5).rounded(to: 1)
                adjustQuantities(state: &state)
                return .none
                
            case .view(.decreaseServingsButtonTapped):
                guard state.currentServings > minServings else { return .none }
                state.currentServings = (state.currentServings - 0.5).rounded(to: 1)
                adjustQuantities(state: &state)
                return .none
                
            case .view(.editButtonTapped):
                return .send(.delegate(.editRecipe(state.recipe)))
                
            case .view(.deleteButtonTapped):
                // TODO: 레시피 삭제 기능 연결
                state.destination = .confirmDeletion(.deleteRecipe)
                return .none
                
            case .view(.reportButtonTapped):
                // TODO: 신고 기능 ㅇ녀결
                return .send(.delegate(.reportRecipe(id: state.recipe.id)))
                
            case .view(.presentFloater(let item)):
                state.floaterItem = item
                return .none
                
            case .internal(.recipeDetailResponse(.success(let recipe))):
                state.isLoading = false
                state.recipe = recipe
                state.currentServings = recipe.servingsCount ?? 1
                state.originalIngredients = recipe.ingredients
                state.originalSources = recipe.sources
                adjustQuantities(state: &state)
                return .none
                
            case .internal(.recipeDetailResponse(.failure)):
                state.isLoading = false
                let item = FloaterItem(role: .warning, message: FloaterMessageNamespace.unknownErrorOccurred.message)
                return .send(.view(.presentFloater(item)))
                
            case .internal(.authStateChanged(let authState)):
                state.authState = authState
                return .none
                
            case .internal(.deleteResponse(.success)):
                state.isLoading = false
                return .send(.delegate(.recipeDeleted(id: state.recipe.id)))
                
            case .internal(.deleteResponse(.failure)):
                state.isLoading = false
                return .none
                
            case .delegate, .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination) { Destination() }
    }
    
    private func adjustQuantities(state: inout State) {
        let originalServings = state.recipe.servingsCount ?? 1
        guard originalServings > 0 else { return }
        let ratio = state.currentServings / originalServings
        
        state.adjustedIngredients = calculateAdjustedQuantities(for: state.originalIngredients, ratio: ratio)
        state.adjustedSources = calculateAdjustedQuantities(for: state.originalSources, ratio: ratio)
    }
    
    private func calculateAdjustedQuantities(for items: [Ingredient], ratio: Decimal) -> [Ingredient] {
        return items.map {
            var ingredient = $0
            for unit in MeasurementUnit.allCases {
                guard let value = $0.units[unit] else { continue }
                ingredient.units[unit] = (value * ratio).rounded(to: 2)
            }
            return ingredient
        }
    }
}

extension AlertState where Action == RecipeGuideFeature.Destination.Action.ConfirmDeletion {
    static let deleteRecipe = Self {
        TextState("Delete Recipe")
    } actions: {
        ButtonState(role: .destructive, action: .confirmButtonTapped) {
            TextState("Confirm")
        }
        
        ButtonState(role: .cancel) {
            TextState("Cancel")
        }
    } message: {
        TextState("Are you sure you want to delete this recipe? This action cannot be undone.")
    }
}

struct RecipeGuideView: View {
    @Bindable var store: StoreOf<RecipeGuideFeature>
    
    var body: some View {
        ScrollView(.vertical) {
            recipeInformationSection
            
            thickDivider
            
            ingredientSection
            
            thickDivider
            
            detailedStepsSection
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton()
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                if case .loggedIn = store.authState {
                    Menu {
                        if store.isAuthor {
                            Button {
                                store.send(.view(.editButtonTapped))
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            
                            Button(role: .destructive) {
                                store.send(.view(.deleteButtonTapped))
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        
                        Button {
                            store.send(.view(.reportButtonTapped))
                        } label: {
                            Label("Report", systemImage: "exclamationmark.bubble")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                    .tint(.black)
                }
            }
        }
        .task { await store.send(.view(.task)).finish() }
        .overlay {
            if store.isLoading { ProgressView() }
        }
    }
    
    private var thickDivider: some View {
        Rectangle()
            .fill(.gray.opacity(0.3))
            .padding(.vertical)
    }
    
    private var recipeInformationSection: some View {
        VStack(spacing: 12) {
            AsyncImage(url: store.recipe.imageURL, scale: 1.6) { image in
                image
                    .resizable()
                    .aspectRatio(1.6, contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(.gray.opacity(0.3))
                    .aspectRatio(1.6, contentMode: .fill)
            }
            
            Text(store.recipe.name)
                .font(.headline)
            
            if let servingsCount = store.recipe.servingsCount,
               let cost = store.recipe.cost,
               let cookingTime = store.recipe.cookingTime {
                HStack(spacing: 8) {
                    Text("\(servingsCount)인분")
                    
                    Circle()
                        .frame(width: 4, height: 4)
                    
                    Text("\(cost)원")
                    
                    Circle()
                        .frame(width: 4, height: 4)
                    
                    Text("\(cookingTime)분")
                }
                .foregroundStyle(.gray)
            }
            
            Text(store.recipe.authorNickname)
                .foregroundStyle(.gray)
            
            Text(store.recipe.description)
                .multilineTextAlignment(.center)
                .foregroundStyle(.gray)
        }
    }
    
    private var ingredientSection: some View {
        VStack(spacing: 12) {
            Text("Ingredients")
                .font(.title3.bold())
            
            if let servings = store.recipe.servingsCount {
                HStack(spacing: 12) {
                    Button {
                        store.send(.view(.decreaseServingsButtonTapped))
                    } label: {
                        Image(systemName: "minus")
                    }
                    .background(
                        Circle()
                            .fill(.gray.opacity(0.3))
                            .frame(width: 24, height: 24)
                    )
                    .tint(.black)
                    
                    Text("\(servings) \(servings > 1 ? "Servings" : "Serving")")
                        .monospacedDigit()
                        .frame(maxWidth: 120)
                    
                    Button {
                        store.send(.view(.increaseServingsButtonTapped))
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
            }
            
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Basic ingredients")
                        .font(.headline)
                    
                    Rectangle()
                        .frame(height: 2)
                }
                .padding([.top, .horizontal])
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(store.adjustedIngredients.indices, id: \.self) { index in
                            cell(store.adjustedIngredients[index])
                                .id(index)
                                .background(
                                    Rectangle()
                                        .fill(cellBackgroundColor(for: index))
                                )
                        }
                    }
                }
                .contentMargins(.horizontal, 16, for: .automatic)
            }
            
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Source")
                        .font(.headline)
                    
                    Rectangle()
                        .frame(height: 2)
                }
                .padding([.top, .horizontal])
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(store.adjustedSources.indices, id: \.self) { index in
                            cell(store.adjustedSources[index])
                                .id(index)
                                .background(
                                    Rectangle()
                                        .fill(cellBackgroundColor(for: index))
                                )
                        }
                    }
                }
                .contentMargins(.horizontal, 16, for: .automatic)
            }
        }
    }
    
    private var detailedStepsSection: some View {
        LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
            ForEach(store.recipe.detailedSteps) { step in
                stepView(step)
                
                thickDivider
            }
        }
    }
    
    @ViewBuilder private func cell(_ item: Ingredient) -> some View {
        VStack(alignment: .listRowSeparatorLeading, spacing: 0) {
            LazyHStack(spacing: 16) {
                Text(item.name)
                    .foregroundStyle(.primary)
                
                if let tablespoon = item.units.tablespoon {
                    Text("\(tablespoon)Tbsp")
                }
                
                if let teaspoon = item.units.teaspoon {
                    Text("\(teaspoon)tsp")
                }
                
                if let cup = item.units.cup {
                    Text("\(cup)cup")
                }
                
                if let gram = item.units.gram {
                    Text("\(gram)g")
                }
                
                if let milliliters = item.units.milliliters {
                    Text("\(milliliters)ml")
                }
                
                if let ounce = item.units.ounce {
                    Text("\(ounce)oz")
                }
                
                if let quantity = item.units.quantity {
                    Text("\(quantity)qty")
                }
            }
            .foregroundStyle(.secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 16)

            Rectangle().fill(.secondary.opacity(0.3))
                .frame(height: 1)
        }
    }
    
    @ViewBuilder private func stepView(_ step: CookingStep) -> some View {
        Section {
            ForEach(step.detailedProcesses) { process in
                detailedProcessCell(process)
            }
            .padding()
        } header: {
            Text(step.title)
                .font(.body)
                .frame(maxWidth: .infinity)
                .safeAreaPadding(.top)
        }
    }
    
    @ViewBuilder private func detailedProcessCell(_ process: CookingDetailedProcess) -> some View {
        VStack {
            if let imageURL = process.imageURL {
                AsyncImage(url: imageURL)
            }
            
            Text(process.description)
                .font(.title)
                .padding(.vertical, 80)
            
            Rectangle()
                .fill(.secondary.opacity(0.2))
                .frame(maxHeight: 2)
        }
    }
    
    private func cellBackgroundColor(for index: Int) -> Color {
        return index.isOdd ? .secondary.opacity(0.1) : .clear
    }
}

//
//  RecipeListFeature.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/12/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct RecipeListFeature {
    private enum CancelID { case fetchRecipes }
    
    @ObservableState
    struct State: Equatable {
        static let fetchLimit: Int32 = 16
        
        var recipes: IdentifiedArrayOf<Recipe> = []
        var nextPageID: String?
        var isLoading: Bool = false
        var isErrorOccured: Bool = false
        var didLoadInitially: Bool = false
        var floaterItem: FloaterItem?
    }
    
    enum Action {
        @CasePathable
        enum ViewAction {
            case onAppear
            case refreshTapped
            case lastRecipeAppeared(Recipe)
            case recipeCellTapped(Recipe)
            case presentFloater(FloaterItem?)
        }
        
        @CasePathable
        enum InternalAction {
            case recipesResponse(Result<RecipePage, Error>)
        }
        
        @CasePathable
        enum DelegateAction {
            case routeRecipeDetail(Recipe)
            case onAppear
            case synchronize(recipes: IdentifiedArrayOf<Recipe>, nextPageID: String?)
        }
        
        case view(ViewAction)
        case `internal`(InternalAction)
        case delegate(DelegateAction)
    }
    
    @Dependency(\.recipeClient) var recipeClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(.onAppear):
                return .concatenate(
                    .send(.delegate(.onAppear)),
                    .run { [didLoadInitially = state.didLoadInitially] send in
                        guard didLoadInitially == false else { return }
                        await send(.view(.refreshTapped))
                    }
                )
                
            case .view(.refreshTapped):
                state.isErrorOccured = false
                state.isLoading = true
                state.recipes.removeAll()
                state.nextPageID = nil
                return fetchRecipes(pageID: state.nextPageID)
                
            case .view(.lastRecipeAppeared(let recipe)):
                let thresholdIndex = state.recipes.index(state.recipes.endIndex, offsetBy: -5)
                guard state.nextPageID != nil,
                      state.isLoading == false,
                      let index = state.recipes.firstIndex(where: { $0.id == recipe.id }),
                      index >= thresholdIndex
                else { return .none }
                state.isLoading = true
                return fetchRecipes(pageID: state.nextPageID)
                
            case .view(.recipeCellTapped(let recipe)):
                return .send(.delegate(.routeRecipeDetail(recipe)))
                
            case .view(.presentFloater(let item)):
                state.floaterItem = item
                return .none
                
            case .internal(.recipesResponse(.success(let page))):
                state.isLoading = false
                state.isErrorOccured = false
                
                if state.didLoadInitially == false { state.didLoadInitially = true }
                if state.didLoadInitially {
                    state.recipes.append(contentsOf: page.recipes)
                } else {
                    state.recipes = IdentifiedArray(uniqueElements: page.recipes)
                }
                state.nextPageID = page.nextPageID
                return .send(.delegate(.synchronize(recipes: state.recipes, nextPageID: state.nextPageID)))
                
            case .internal(.recipesResponse(.failure)):
                state.isLoading = false
                guard state.recipes.isEmpty == false else {
                    state.isErrorOccured = true
                    return .none
                }
                let item = FloaterItem(role: .warning, message: FloaterMessageNamespace.unknownErrorOccurred.message)
                state.floaterItem = item
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
    
    private func fetchRecipes(pageID: String?) -> Effect<Action> {
        return .run { send in
            do {
                let page = try await recipeClient.readPage(pageID, State.fetchLimit)
                await send(.internal(.recipesResponse(.success(page))))
            } catch {
                await send(.internal(.recipesResponse(.failure(error))))
            }
        }
        .cancellable(id: CancelID.fetchRecipes, cancelInFlight: true)
    }
}

struct RecipeListView: View {
    struct Constants {
        static let errorPageTitle: String = "Something went wrong..\nPlease try again."
        static let errorPageSubtitle: String = "If the issue persists,\nplease reach out to customer service."
    }
    
    @Bindable var store: StoreOf<RecipeListFeature>
    
    private let column: [GridItem] = [
        .init(.adaptive(minimum: 120, maximum: .infinity)),
        .init(.adaptive(minimum: 120, maximum: .infinity))
    ]
    
    var body: some View {
        if store.isErrorOccured {
            unavailableView
        } else {
            ScrollView(.vertical) {
                LazyVGrid(columns: column, spacing: 8) {
                    ForEach(store.recipes) { recipe in
                        recipeCell(recipe)
                            .onAppear { store.send(.view(.lastRecipeAppeared(recipe))) }
                    }
                }
                .padding(.horizontal)
                
                if store.isLoading {
                    ProgressView()
                }
            }
            .onAppear {
                store.send(.view(.onAppear))
            }
            .refreshable { store.send(.view(.refreshTapped)) }
            .floater($store.floaterItem.sending(\.view.presentFloater))
        }
    }
    
    @ViewBuilder private func recipeCell(_ recipe: Recipe) -> some View {
        VStack(spacing: 12) {
            AsyncImage(url: recipe.imageURL) { image in
                image
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(.gray.opacity(0.3))
                    .aspectRatio(1, contentMode: .fill)
            }
            .clipShape(RoundedRectangle(cornerRadius: 5))
            
            HStack{
                VStack(alignment: .leading, spacing: 4) {
                    Text(recipe.name)
                        .font(.headline)
                    
                    if let servingsCount = recipe.servingsCount,
                       let cost = recipe.cost,
                       let cookingTime = recipe.cookingTime {
                        HStack(spacing: 8) {
                            Text("\(servingsCount)serv")
                            
                            Circle()
                                .frame(width: 4, height: 4)
                            
                            Text("$\(cost)")
                            
                            Circle()
                                .frame(width: 4, height: 4)
                            
                            Text("\(cookingTime)min")
                        }
                        .font(.subheadline)
                    }
                    
                    Text(recipe.authorNickname)
                        .font(.subheadline)
                }
                
                Spacer()
            }
        }
        .clipShape(.rect)
        .onTapGesture {
            store.send(.view(.recipeCellTapped(recipe)))
        }
    }
    
    private var unavailableView: some View {
        VStack(spacing: 20) {
            Image(.frown)
                .resizable()
                .frame(width: 40, height: 40)
            
            Text("oops!")
                .font(.title)
            
            Text(Constants.errorPageTitle)
                .foregroundStyle(.secondary)
            
            Button {
                store.send(.view(.refreshTapped))
            } label: {
                Text("Refresh Page")
                    .padding()
                    .bold()
            }
            .buttonStyle(.roundedProminent(foreground: .white, background: .black, isLoading: store.isLoading))
            .disabled(store.isLoading)
            
            Text(Constants.errorPageSubtitle)
                .foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.center)
    }
}

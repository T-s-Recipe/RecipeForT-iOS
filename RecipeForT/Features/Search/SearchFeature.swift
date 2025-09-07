//
//  SearchFeature.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/12/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct SearchFeature {
    private enum CancelID { case search }
    
    @ObservableState
    struct State: Equatable {
        enum Entity: Equatable {
            case loading
            case loaded(recipes: IdentifiedArrayOf<Recipe>)
            case notFound
        }
        
        var entity: Entity = .loaded(recipes: [])
        var searchingText: String = String()
    }
    
    enum Action {
        @CasePathable
        enum ViewAction {
            case textChanged(String)
            case textSubmitted
        }
        
        @CasePathable
        enum InternalAction {
            case searchResponse(Result<[Recipe], Error>)
        }
        
        @CasePathable
        enum Delegate {
            case recipeCellTapped(Recipe)
        }
        
        case view(ViewAction)
        case `internal`(InternalAction)
        case delegate(Delegate)
    }
    
    @Dependency(\.recipeClient) var recipeClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(.textChanged(let text)):
                state.searchingText = text
                return .none
                
            case .view(.textSubmitted):
                guard state.searchingText.isEmpty == false else {
                    state.entity = .loaded(recipes: [])
                    return .cancel(id: CancelID.search)
                }
                
                state.entity = .loading
                return .run { send in
                    do {
                        // TODO: 검색 API 추가 후 구현
                        let recipes = try await recipeClient.readRecipe("mock")
                        await send(.internal(.searchResponse(.success([recipes]))))
                    } catch {
                        await send(.internal(.searchResponse(.failure(error))))
                    }
                }
                .cancellable(id: CancelID.search, cancelInFlight: true)
                
            case .internal(.searchResponse(.success(let recipes))):
                state.entity = recipes.isEmpty ? .notFound : .loaded(recipes: .init(uniqueElements: recipes))
                return .none
                
            case .internal(.searchResponse(.failure)):
                state.entity = .notFound
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
}

struct SearchView: View {
    struct Constants {
        static let errorPageTitle: String = "No Result Found"
        static let errorPageSubtitle: String = "Can't find what you're looking for?\nJust let us know and we'll add it for you!"
    }
    
    @Bindable var store: StoreOf<SearchFeature>
    
    private let columns: [GridItem] = [
        .init(.adaptive(minimum: 120, maximum: .infinity)),
        .init(.adaptive(minimum: 120, maximum: .infinity))
    ]
    
    var body: some View {
        VStack {
            SearchBar(text: $store.searchingText.sending(\.view.textChanged)) { store.send(.view(.textSubmitted)) }
            
            switch store.entity {
            case .loaded(let recipes):
                ScrollView(.vertical) {
                    LazyVGrid(columns: columns) {
                        ForEach(recipes) { recipe in
                            recipeCell(recipe)
                        }
                    }
                }
                
            case .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            case .notFound:
                unavailableView
            }
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
            store.send(.delegate(.recipeCellTapped(recipe)))
        }
    }
    
    private var unavailableView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "exclamationmark.magnifyingglass")
                .resizable()
                .frame(width: 52, height: 52)
                .foregroundStyle(.gray)
            
            Text(Constants.errorPageTitle)
                .fontWeight(.bold)
            
            Text(Constants.errorPageSubtitle)
                .multilineTextAlignment(.center)
                .foregroundStyle(.gray)
            
//            Button {
//                // TODO: 무슨 비즈니스를 수행하는지 확인 필요
//            } label: {
//                Text("Request this recipe!")
//            }
//            .buttonStyle(.borderedProminent)
//            .tint(.black)
            
            Spacer()
        }
    }
}

// MARK: - Subviews
extension SearchView {
    struct SearchBar: View {
        @Binding var text: String
        @FocusState private var isFocused: Bool
        
        let onSubmit: () -> Void
        
        var body: some View {
            HStack {
                HStack {
                    TextField("Search Keywords", text: $text)
                        .focused($isFocused)
                        .submitLabel(.search)
                        .onSubmit(onSubmit)
                        
                    if text.isEmpty == false {
                        Button {
                            removeText()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                        }
                        .tint(.gray.opacity(0.3))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.clear)
                        .strokeBorder(isFocused ? .black : .gray.opacity(0.3))
                )
                
                if isFocused {
                    Button {
                        removeText()
                        releaseFocus()
                    } label: {
                        Text("Cancel")
                    }
                    .tint(.black)
                    .transition(.push(from: .leading))
                }
            }
            .animation(.smooth, value: isFocused)
            .padding()
        }
        
        private func removeText() {
            text.removeAll()
        }
        
        private func releaseFocus() {
            isFocused = false
        }
    }
}

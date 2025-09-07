//
//  RootFeature.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/11/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct Path {
    @ObservableState
    enum State: Equatable {
        case recipeGuide(RecipeGuideFeature.State)
    }
    
    enum Action {
        case recipeGuide(RecipeGuideFeature.Action)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.recipeGuide, action: \.recipeGuide) { RecipeGuideFeature() }
    }
}

@Reducer
struct Presentation {
    @ObservableState
    enum State: Equatable {
        case editRecipe(EditRecipeFeature.State)
        case auth(AuthFeature.State)
    }
    
    enum Action {
        case editRecipe(EditRecipeFeature.Action)
        case auth(AuthFeature.Action)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.editRecipe, action: \.editRecipe) { EditRecipeFeature() }
        Scope(state: \.auth, action: \.auth) { AuthFeature() }
    }
}

@Reducer
struct RootFeature {
    enum TabSelection: Hashable, Comparable {
        case main, search, recipeUpload, preferences
    }
    
    private enum CancelID {
        case authStateSubscription
    }
    
    @ObservableState
    struct State: Equatable {
        var recipeList = RecipeListFeature.State()
        var search = SearchFeature.State()
        var preference = PreferenceFeature.State(authState: .loggedOut)
        
        var currentTab: TabSelection = .main
        var path = StackState<Path.State>()
        var authState: AuthenticationState = .loggedOut
        @Presents var presentation: Presentation.State?
        
        var recipes: IdentifiedArrayOf<Recipe> = []
        var recipeNextPageID: String?
        
        // 로그인 완료 후 이동할 목적지 탭 저장용
        var postLoginDestination: TabSelection?
    }
    
    enum Action {
        @CasePathable
        enum ViewAction {
            case onAppear
            case tabChanged(to: TabSelection)
        }
        
        @CasePathable
        enum InternalAction {
            case authStateChanged(AuthenticationState)
        }
        
        case view(ViewAction)
        case `internal`(InternalAction)
        
        case recipeList(RecipeListFeature.Action)
        case search(SearchFeature.Action)
        case preference(PreferenceFeature.Action)
        
        case path(StackAction<Path.State, Path.Action>)
        case presentation(PresentationAction<Presentation.Action>)
    }
    
    @Dependency(\.authClient) var authClient
    
    var body: some Reducer<State, Action> {
        Scope(state: \.recipeList, action: \.recipeList) { RecipeListFeature() }
        Scope(state: \.search, action: \.search) { SearchFeature() }
        Scope(state: \.preference, action: \.preference) { PreferenceFeature() }
        
        Reduce { state, action in
            switch action {
            case .view(.onAppear):
                return .run { send in
                    for await authState in authClient.authenticationState() {
                        await send(.internal(.authStateChanged(authState)))
                    }
                }
                .cancellable(id: CancelID.authStateSubscription)
                
            case .view(.tabChanged(let tab)):
                switch tab {
                case .main, .search:
                    state.currentTab = tab
                    return .none
                    
                case .recipeUpload:
                    guard case .loggedIn = state.authState else {
                        state.postLoginDestination = .recipeUpload
                        state.presentation = .auth(.init())
                        return .none
                    }
                    state.presentation = .editRecipe(.init(recipe: nil))
                    return .none
                    
                case .preferences:
                    guard case .loggedIn = state.authState else {
                        state.postLoginDestination = .preferences
                        state.presentation = .auth(.init())
                        return .none
                    }
                    state.currentTab = tab
                    return .none
                }
                
            case .internal(.authStateChanged(let newState)):
                state.authState = newState
                state.preference.authState = newState
                if newState == .loggedOut { state.currentTab = .main }
                return .none
                
            case .recipeList(.delegate(let delegateAction)):
                switch delegateAction {
                case .routeRecipeDetail(let recipe):
                    state.path.append(.recipeGuide(.init(recipe: recipe)))
                    return .none
                    
                case .onAppear:
                    guard state.recipes.isEmpty == false else { return .none }
                    state.recipeList.recipes = state.recipes
                    state.recipeList.nextPageID = state.recipeNextPageID
                    state.recipeList.didLoadInitially = true
                    return .none
                    
                case let .synchronize(recipes, nextPageID):
                    state.recipes = recipes
                    state.recipeNextPageID = nextPageID
                    return .none
                }
                
            case .search(.delegate(let delegateAction)):
                switch delegateAction {
                case .recipeCellTapped(let recipe):
                    state.path.append(.recipeGuide(.init(recipe: recipe)))
                    return .none
                }
                
            case .preference(.delegate(let delegateAction)):
                switch delegateAction {
                case .presentNotices:
                    // TODO: 목록 화면으로 이동
                    return .none
                case .presentInquiries:
                    // TODO: 목록 화면으로 이동
                    return .none
                }
                
            case .path(_):
                return .none
                
            case .presentation(.dismiss):
                guard let destination = state.postLoginDestination,
                      case .loggedIn = state.authState
                else {
                    state.postLoginDestination = nil
                    return .none
                }
                state.postLoginDestination = nil
                if destination == .recipeUpload {
                    state.presentation = .editRecipe(.init(recipe: nil))
                    return .none
                }
                
                state.currentTab = destination
                return .none
                
            case .presentation(.presented(let presentedAction)):
                switch presentedAction {
                case .editRecipe(.delegate(.saveCompleted)):
                    state.presentation = nil
                    return .none
                    
                default:
                    return .none
                }
            
            case .recipeList, .search, .preference:
                return .none
            }
        }
        .forEach(\.path, action: \.path) { Path() }
        .ifLet(\.$presentation, action: \.presentation) { Presentation() }
    }
}

struct RootView: View {
    @Bindable var store: StoreOf<RootFeature>
    
    var body: some View {
        NavigationStackStore(store.scope(state: \.path, action: \.path)) {
            TabView(selection: $store.currentTab.sending(\.view.tabChanged)) {
                Tab(value: RootFeature.TabSelection.main) {
                    RecipeListView(store: store.scope(state: \.recipeList, action: \.recipeList))
                } label: {
                    Image(systemName: "house")
                        .environment(\.symbolVariants, .none)
                }
                
                Tab(value: RootFeature.TabSelection.search) {
                    SearchView(store: store.scope(state: \.search, action: \.search))
                } label: {
                    Image(systemName: "magnifyingglass")
                }
                
                Tab(value: RootFeature.TabSelection.recipeUpload) {
                    EmptyView()
                } label: {
                    Image(systemName: "plus.circle")
                        .environment(\.symbolVariants, .none)
                }
                
                Tab(value: RootFeature.TabSelection.preferences) {
                    PreferenceView(store: store.scope(state: \.preference, action: \.preference))
                } label: {
                    Image(systemName: "person")
                        .environment(\.symbolVariants, .none)
                }
            }
            .tint(.red)
        } destination: { store in
            switch store.state {
            case .recipeGuide:
                if let recipeGuideStore = store.scope(state: \.recipeGuide, action: \.recipeGuide) {
                    RecipeGuideView(store: recipeGuideStore)
                }
            }
        }
        .fullScreenCover(item: $store.scope(state: \.presentation, action: \.presentation)) { presentationStore in
            switch presentationStore.state {
            case .auth:
                if let authStore = presentationStore.scope(state: \.auth, action: \.auth) {
                    AuthView(store: authStore)
                }
            case .editRecipe:
                if let editRecipeStore = presentationStore.scope(state: \.editRecipe, action: \.editRecipe) {
                    EditRecipeView(store: editRecipeStore)
                }
            }
        }
        .task {
            await store.send(.view(.onAppear)).finish()
        }
    }
}

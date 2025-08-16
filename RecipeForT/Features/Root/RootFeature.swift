//
//  RootFeature.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/11/25.
//

import SwiftUI

@MainActor
struct RootFeature {
    typealias TabSelection = RootState.TabSelection
    
    @Environment(\.router) private var router
    @Environment(\.memberRepository) private var memberRepository
    @State private var state = RootState()
}

// MARK: - ViewFeature Conformation
extension RootFeature: ViewFeature {
    enum UIEvent {
        case tabChanged(to: TabSelection)
    }
    
    func notify(_ event: UIEvent) {
        switch event {
        case .tabChanged(let to):
            switch to {
            case .recipeUpload, .preferences:
                guard memberRepository.isLoggedIn else { return router.route(to: .loginView) }
                router.route(to: .editRecipeView(recipe: nil))
                
            default:
                state.updateTab(to: to)
            }
        }
    }
}

// MARK: - View Conformation
extension RootFeature: View {
    var body: some View {
        @Bindable var router = router
        
        NavigationStack(path: $router.path) {
            TabView(selection: Binding(
                get: { state.currentTab },
                set: { notify(.tabChanged(to: $0)) }
            )) {
                Tab(value: TabSelection.main) {
                    router.view(to: .mainView)
                } label: {
                    Image(systemName: "house")
                        .environment(\.symbolVariants, .none)
                }
                
                Tab(value: TabSelection.search) {
                    router.view(to: .searchView)
                } label: {
                    Image(systemName: "magnifyingglass")
                }
                
                Tab(value: TabSelection.recipeUpload) {
                    EmptyView()
                } label: {
                    Image(systemName: "plus.circle")
                        .environment(\.symbolVariants, .none)
                }
                
                Tab(value: TabSelection.preferences) {
                    router.view(to: .myPageView)
                } label: {
                    Image(systemName: "person")
                        .environment(\.symbolVariants, .none)
                }
            }
            .navigationDestination(for: Router.Destination.self) { destination in
                router.view(to: destination)
            }
            .sheet(item: $router.sheet) { destination in
                router.view(to: destination)
            }
            .fullScreenCover(item: $router.fullScreenCover) { destination in
                router.view(to: destination)
            }
            .tint(.red)
        }
        .floater($router.floater)
    }
}

#Preview {
    RootFeature()
}

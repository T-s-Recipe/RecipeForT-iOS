//
//  RootFeature.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/11/25.
//

import SwiftUI

struct RootFeature {
    typealias TabSelection = RootState.TabSelection
    
    @Environment(\.router) private var router
    @State private var state = RootState()
}

// MARK: - ViewFeature Conformation
extension RootFeature: ViewFeature {
    enum UIEvent {
        case tabChanged(old: TabSelection, new: TabSelection)
    }
    
    func notify(_ event: UIEvent) {
        switch event {
        case .tabChanged(_, let new):
            state.updateTab(to: new)
            
            guard case .recipeUpload = new else { return }
            router.route(to: .editRecipeView(recipe: nil))
        }
    }
}

// MARK: - View Conformation
extension RootFeature: View {
    var body: some View {
        @Bindable var router = router
        
        NavigationStack(path: $router.path) {
            TabView(selection: $state.currentTab) {
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
            .fullScreenCover(item: $router.fullScreenCover) {
                guard case .recipeUpload = state.currentTab else { return }
                notify(.tabChanged(old: state.currentTab, new: state.previousTab))
            } content: { destination in
                router.view(to: destination)
            }
            .onChange(of: state.currentTab) { previous, current in
                notify(.tabChanged(old: previous, new: current))
            }
        }
        .floater($router.floater)
    }
}

#Preview {
    RootFeature()
}

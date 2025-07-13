//
//  ContentView.swift
//  RecipeForT
//
//  Created by Swain Yun on 6/8/25.
//

import SwiftUI

@Observable
final class TabSelector {
    enum TabSelection: Hashable {
        case main
        case search
        case recipeUpload
        case myPage
    }
    
    var currentTab: TabSelection = .main
    @ObservationIgnored var previousTab: TabSelection = .main
    
    func backToPreviousTab() {
        currentTab = previousTab
    }
}

struct ContentView: View {
    @StateObject private var router = Router()
    @State private var tabSelector = TabSelector()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            @Bindable var tabSelector = tabSelector
            
            TabView(selection: $tabSelector.currentTab) {
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
                
                Tab(value: TabSelection.myPage) {
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
                guard case .recipeUpload = tabSelector.currentTab else { return }
                tabSelector.backToPreviousTab()
            } content: { destination in
                router.view(to: destination)
            }
            .onChange(of: tabSelector.currentTab) { previous, current in
                tabSelector.previousTab = previous
                
                guard case .recipeUpload = current else { return }
                router.route(to: .editRecipeView(recipe: nil))
            }
        }
        .environmentObject(router)
    }
}

extension ContentView {
    typealias TabSelection = TabSelector.TabSelection
}

#Preview {
    ContentView()
}

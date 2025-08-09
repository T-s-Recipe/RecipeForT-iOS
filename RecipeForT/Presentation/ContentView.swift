//
//  ContentView.swift
//  RecipeForT
//
//  Created by Swain Yun on 6/8/25.
//

import SwiftUI
import Swinject

@Observable
final class TabSelector {
    enum TabSelection: Hashable {
        case main
        case search
        case recipeUpload
        case myPage
    }
    
    var isLoggedIn: Bool { memberRepository.isLoggedIn }
    var currentTab: TabSelection = .main
    @ObservationIgnored var previousTab: TabSelection = .main
    
    private let memberRepository: MemberRepositoryProtocol
    
    init(resolver: Resolver) {
        self.memberRepository = resolver.resolve(MemberRepositoryProtocol.self)!
    }
    
    func backToPreviousTab() {
        currentTab = previousTab
    }
}

struct ContentView: View {
    @StateObject private var router: Router
    @State private var tabSelector: TabSelector
    
    init(resolver: Resolver) {
        self._router = StateObject(wrappedValue: Router(resolver: resolver))
        self.tabSelector = TabSelector(resolver: resolver)
    }
    
    var body: some View {
        NavigationStack(path: $router.path) {
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
        .floater($router.floater)
        .environmentObject(router)
    }
}

extension ContentView {
    typealias TabSelection = TabSelector.TabSelection
}

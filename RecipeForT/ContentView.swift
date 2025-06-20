//
//  ContentView.swift
//  RecipeForT
//
//  Created by Swain Yun on 6/8/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var router = Router()
    @State private var selection: TabSelection = .main
    
    var body: some View {
        NavigationStack(path: $router.path) {
            TabView(selection: $selection) {
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
                    router.view(to: .recipeUploadView)
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
            .fullScreenCover(item: $router.fullScreenCover) { destination in
                router.view(to: destination)
            }
        }
        .environmentObject(router)
    }
}

// MARK: - Nested Types
extension ContentView {
    enum TabSelection: Hashable {
        case main
        case search
        case recipeUpload
        case myPage
    }
}

#Preview {
    ContentView()
}

//
//  RecipeForTApp.swift
//  RecipeForT
//
//  Created by Swain Yun on 6/8/25.
//

import SwiftUI
import GoogleSignIn
import ComposableArchitecture

@main
struct RecipeForTApp: App {
    @State var store: StoreOf<RootFeature> = .init(initialState: .init()) { RootFeature() }
    
    var body: some Scene {
        WindowGroup {
            RootView(store: store)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
                .preferredColorScheme(.light)
        }
    }
}

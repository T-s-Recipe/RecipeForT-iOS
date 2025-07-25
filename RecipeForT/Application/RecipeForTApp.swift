//
//  RecipeForTApp.swift
//  RecipeForT
//
//  Created by Swain Yun on 6/8/25.
//

import SwiftUI
import Swinject

@main
struct RecipeForTApp: App {
    private let resolver: Resolver = {
        let assembler = Assembler([
            PresentationAssembly(),
            DomainAssembly(),
            RepositoryAssembly(),
            InfrastructureAssembly()
        ])
        return assembler.resolver
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView(resolver: resolver)
        }
    }
}

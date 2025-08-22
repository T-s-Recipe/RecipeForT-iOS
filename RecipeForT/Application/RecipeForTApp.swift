//
//  RecipeForTApp.swift
//  RecipeForT
//
//  Created by Swain Yun on 6/8/25.
//

import SwiftUI
import Swinject
import GoogleSignIn

@main
struct RecipeForTApp: App {
    private let resolver: Resolver = {
        let assembler = Assembler([
            DomainAssembly(),
            RepositoryAssembly(),
            InfrastructureAssembly()
        ])
        return assembler.resolver
    }()
    
    var body: some Scene {
        WindowGroup {
            RootFeature()
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
                .environment(\.router, Router())
                .environment(\.recipeRepository, resolver.resolve(RecipeRepositoryProtocol.self)!)
                .environment(\.memberRepository, resolver.resolve(MemberRepositoryProtocol.self)!)
                .environment(\.supportRepository, resolver.resolve(SupportRepositoryProtocol.self)!)
                .preferredColorScheme(.light)
        }
    }
}

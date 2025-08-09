//
//  MainView.swift
//  RecipeForT
//
//  Created by Swain Yun on 6/8/25.
//

import SwiftUI
import Swinject

struct MainView: View {
    @EnvironmentObject private var router: Router
    @State private var recipeLibrary: RecipeLibrary
    
    private let column: [GridItem] = [
        .init(.adaptive(minimum: 120, maximum: .infinity)),
        .init(.adaptive(minimum: 120, maximum: .infinity))
    ]
    
    init(resolver: Resolver) {
        recipeLibrary = RecipeLibrary(resolver: resolver)
    }
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: column, spacing: 8) {
                ForEach(recipeLibrary.recipes) { recipe in
                    Cell(recipe: recipe)
                        .onAppear {
                            recipeLibrary.loadRecipesIfNeeded(recipe.id)
                        }
                }
            }
            .padding(.horizontal)
            
            if recipeLibrary.isLoading {
                ProgressView()
                    .padding()
            }
        }
        .task {
            recipeLibrary.loadRecipes()
        }
        .refreshable {
            recipeLibrary.refresh()
        }
        .onChange(of: recipeLibrary.floater) { _, newValue in
            guard let item = newValue else { return }
            router.presentFloater(role: item.role, message: item.message)
        }
    }
}

// MARK: - Subviews
extension MainView {
    struct Cell: View {
        @EnvironmentObject private var router: Router
        
        let recipe: Recipe
        
        var body: some View {
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
                router.route(to: .recipeGuideView(recipe))
            }
        }
    }
}

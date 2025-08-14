//
//  RecipeListFeature.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/12/25.
//

import SwiftUI

@MainActor
struct RecipeListFeature {
    @Environment(\.router) private var router
    @Environment(\.recipeRepository) private var recipeRepository
    @State private var state = RecipeListState()
    
    private let column: [GridItem] = [
        .init(.adaptive(minimum: 120, maximum: .infinity)),
        .init(.adaptive(minimum: 120, maximum: .infinity))
    ]
}

// MARK: - ViewFeature Conformation
extension RecipeListFeature: ViewFeature {
    enum UIEvent {
        case task
        case needToMoreRecipes(pageID: String)
        case refresh
    }
    
    func notify(_ event: UIEvent) {
        switch event {
        case .task:
            loadRecipes(false)
            
        case .needToMoreRecipes(let pageID):
            loadMoreRecipes(pageID)
            
        case .refresh:
            loadRecipes(true)
        }
    }
}

// MARK: - View Conformation
extension RecipeListFeature: View {
    var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: column, spacing: 8) {
                ForEach(state.recipes) { recipe in
                    recipeCell(recipe)
                        .onAppear { notify(.needToMoreRecipes(pageID: recipe.id)) }
                }
            }
            .padding(.horizontal)
            
            if state.isLoading {
                ProgressView()
            }
        }
        .task { notify(.task) }
        .refreshable { notify(.refresh) }
        .onChange(of: state.floaterItem) { _, newValue in
            guard let newValue else { return }
            router.presentFloater(role: newValue.role, message: newValue.message)
        }
    }
    
    @ViewBuilder private func recipeCell(_ recipe: Recipe) -> some View {
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

// MARK: - Methods
private extension RecipeListFeature {
    func loadRecipes(_ isRefreshNeeded: Bool) {
        state.cancelTask(for: #function)
        
        if isRefreshNeeded { state.flush() }
        
        let task = Task {
            state.isLoading = true
            
            do {
                let page = try await recipeRepository.read(pageID: state.nextPageID, limit: state.fetchLimit)
                
                guard Task.isCancelled == false else { return state.isLoading = false }
                
                state.recipes += page.recipes
            } catch {
                state.floaterItem = .init(role: .warning, message: FloaterMessageNamespace.unknownErrorOccurred)
            }
        }
        
        state.storeTask(for: #function, task: task)
    }
    
    func loadMoreRecipes(_ nextPageID: String) {
        guard state.recipes.isEmpty == false,
              state.recipes.last?.id == nextPageID
        else { return }
        
        state.cancelTask(for: #function)
        
        let task = Task {
            state.isLoading = true
            
            do {
                let page = try await recipeRepository.read(pageID: nextPageID, limit: state.fetchLimit)
                
                guard Task.isCancelled == false else { return state.isLoading = false }
                
                state.recipes += page.recipes
                state.nextPageID = page.nextPageID
            } catch {
                state.floaterItem = .init(role: .warning, message: FloaterMessageNamespace.unknownErrorOccurred)
            }
        }
        
        state.storeTask(for: #function, task: task)
    }
}

#Preview {
    RecipeListFeature()
}

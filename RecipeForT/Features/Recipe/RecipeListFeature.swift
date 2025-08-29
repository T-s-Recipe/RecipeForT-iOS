//
//  RecipeListFeature.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/12/25.
//

import SwiftUI

@MainActor
struct RecipeListFeature {
    struct Constants {
        static let errorPageTitle: String = "Something went wrong..\nPlease try again."
        static let errorPageSubtitle: String = "If the issue persists,\nplease reach out to customer service."
    }
    
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
        case needToMoreRecipes(pageID: String)
        case refresh
    }
    
    func notify(_ event: UIEvent) {
        switch event {
        case .needToMoreRecipes(let pageID):
            loadMoreRecipes(pageID)
            
        case .refresh:
            loadRecipes()
        }
    }
}

// MARK: - View Conformation
extension RecipeListFeature: View {
    var body: some View {
        if state.isErrorOccurred {
            unavailableView
        } else {
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
            .task { notify(.refresh) }
            .refreshable { notify(.refresh) }
            .onChange(of: state.floaterItem) { _, newValue in
                guard let newValue else { return }
                router.presentFloater(role: newValue.role, message: newValue.message)
            }
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
    
    private var unavailableView: some View {
        VStack(spacing: 20) {
            Image(.frown)
                .resizable()
                .frame(width: 40, height: 40)
            
            Text("oops!")
                .font(.title)
            
            Text(Constants.errorPageTitle)
                .foregroundStyle(.secondary)
            
            Button {
                notify(.refresh)
            } label: {
                Text("Refresh Page")
                    .padding()
                    .bold()
            }
            .buttonStyle(.roundedProminent(foreground: .white, background: .black, isLoading: state.isLoading))
            
            Text(Constants.errorPageSubtitle)
                .foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.center)
    }
}

// MARK: - Methods
private extension RecipeListFeature {
    func loadRecipes() {
        state.cancelTask(for: #function)
        
        let task = Task {
            state.isErrorOccurred = false
            state.isLoading = true
            defer { state.isLoading = false }
            
            do {
                let page = try await recipeRepository.read(pageID: state.nextPageID, limit: state.fetchLimit)
                
                guard Task.isCancelled == false else { return }
                
                state.recipes = page.recipes
            } catch {
                state.isErrorOccurred = true
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
            defer { state.isLoading = false }
            
            do {
                let page = try await recipeRepository.read(pageID: nextPageID, limit: state.fetchLimit)
                
                guard Task.isCancelled == false else { return }
                
                state.recipes += page.recipes
                state.nextPageID = page.nextPageID
            } catch {
                state.floaterItem = .init(role: .warning, message: FloaterMessageNamespace.unknownErrorOccurred.message)
            }
        }
        
        state.storeTask(for: #function, task: task)
    }
}

#Preview {
    RecipeListFeature()
}

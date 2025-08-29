//
//  RecipeGuideFeature.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/12/25.
//

import SwiftUI

@MainActor
struct RecipeGuideFeature {
    @Environment(\.router) private var router
    @Environment(\.recipeRepository) private var recipeRepository
    @State private var state: RecipeGuideState = RecipeGuideState()
    
    @Bindable var recipe: Recipe
}

// MARK: - ViewFeature Conformation
extension RecipeGuideFeature: ViewFeature {
    enum UIEvent {
        case task
        case increaseServing
        case decreaseServing
    }
    
    func notify(_ event: UIEvent) {
        switch event {
        case .task:
            fetchRecipeDetails()
        case .increaseServing:
            state.increaseServing()
        case .decreaseServing:
            state.decreaseServing()
        }
    }
}

// MARK: - View Conformation
extension RecipeGuideFeature: View {
    var body: some View {
        ScrollView(.vertical) {
            recipeInformationSection
            
            thickDivider
            
            ingredientSection
            
            thickDivider
            
            detailedStepsSection
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton()
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        
                    } label: {
                        Text("Edit")
                    }
                    
                    Button {
                        
                    } label: {
                        Text("Delete")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
                .tint(.black)
            }
        }
    }
    
    private var thickDivider: some View {
        Rectangle()
            .fill(.gray.opacity(0.3))
            .padding(.vertical)
    }
    
    private var recipeInformationSection: some View {
        VStack(spacing: 12) {
            AsyncImage(url: recipe.imageURL, scale: 1.6) { image in
                image
                    .resizable()
                    .aspectRatio(1.6, contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(.gray.opacity(0.3))
                    .aspectRatio(1.6, contentMode: .fill)
            }
            
            Text(recipe.name)
                .font(.headline)
            
            if let servingsCount = recipe.servingsCount,
               let cost = recipe.cost,
               let cookingTime = recipe.cookingTime {
                HStack(spacing: 8) {
                    Text("\(servingsCount)인분")
                    
                    Circle()
                        .frame(width: 4, height: 4)
                    
                    Text("\(cost)원")
                    
                    Circle()
                        .frame(width: 4, height: 4)
                    
                    Text("\(cookingTime)분")
                }
                .foregroundStyle(.gray)
            }
            
            Text(recipe.authorNickname)
                .foregroundStyle(.gray)
            
            Text(recipe.description)
                .multilineTextAlignment(.center)
                .foregroundStyle(.gray)
        }
    }
    
    private var ingredientSection: some View {
        VStack(spacing: 12) {
            Text("Ingredients")
                .font(.title3.bold())
            
            if let servings = state.servings {
                HStack(spacing: 12) {
                    Button {
                        notify(.decreaseServing)
                    } label: {
                        Image(systemName: "minus")
                    }
                    .background(
                        Circle()
                            .fill(.gray.opacity(0.3))
                            .frame(width: 24, height: 24)
                    )
                    .tint(.black)
                    
                    Text("\(servings) \(servings > 1 ? "Servings" : "Serving")")
                        .monospacedDigit()
                        .frame(maxWidth: 120)
                    
                    Button {
                        notify(.increaseServing)
                    } label: {
                        Image(systemName: "plus")
                    }
                    .background(
                        Circle()
                            .fill(.gray.opacity(0.3))
                            .frame(width: 24, height: 24)
                    )
                    .tint(.black)
                }
            }
            
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Basic ingredients")
                        .font(.headline)
                    
                    Rectangle()
                        .frame(height: 2)
                }
                .padding([.top, .horizontal])
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(state.ingredients.indices, id: \.self) { index in
                            cell(state.ingredients[index])
                                .id(index)
                                .background(
                                    Rectangle()
                                        .fill(cellBackgroundColor(for: index))
                                )
                        }
                    }
                }
                .contentMargins(.horizontal, 16, for: .automatic)
            }
            
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Source")
                        .font(.headline)
                    
                    Rectangle()
                        .frame(height: 2)
                }
                .padding([.top, .horizontal])
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(state.sources.indices, id: \.self) { index in
                            cell(state.sources[index])
                                .id(index)
                                .background(
                                    Rectangle()
                                        .fill(cellBackgroundColor(for: index))
                                )
                        }
                    }
                }
                .contentMargins(.horizontal, 16, for: .automatic)
            }
        }
    }
    
    private var detailedStepsSection: some View {
        LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
            ForEach(state.detailedSteps) { step in
                stepView(step)
                
                thickDivider
            }
        }
    }
    
    @ViewBuilder private func cell(_ item: Ingredient) -> some View {
        VStack(alignment: .listRowSeparatorLeading, spacing: 0) {
            LazyHStack(spacing: 16) {
                Text(item.name)
                    .foregroundStyle(.primary)
                
                if let tablespoon = item.units.tablespoon {
                    Text("\(tablespoon)Tbsp")
                }
                
                if let teaspoon = item.units.teaspoon {
                    Text("\(teaspoon)tsp")
                }
                
                if let cup = item.units.cup {
                    Text("\(cup)cup")
                }
                
                if let gram = item.units.gram {
                    Text("\(gram)g")
                }
                
                if let milliliters = item.units.milliliters {
                    Text("\(milliliters)ml")
                }
                
                if let ounce = item.units.ounce {
                    Text("\(ounce)oz")
                }
                
                if let quantity = item.units.quantity {
                    Text("\(quantity)qty")
                }
            }
            .foregroundStyle(.secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 16)

            Rectangle().fill(.secondary.opacity(0.3))
                .frame(height: 1)
        }
    }
    
    @ViewBuilder private func stepView(_ step: CookingStep) -> some View {
        Section {
            ForEach(step.detailedProcesses) { process in
                detailedProcessCell(process)
            }
            .padding()
        } header: {
            Text(step.title)
                .font(.body)
                .frame(maxWidth: .infinity)
                .safeAreaPadding(.top)
        }
    }
    
    @ViewBuilder private func detailedProcessCell(_ process: CookingDetailedProcess) -> some View {
        VStack {
            if let imageURL = process.imageURL {
                AsyncImage(url: imageURL)
            }
            
            Text(process.description)
                .font(.title)
                .padding(.vertical, 80)
            
            Rectangle()
                .fill(.secondary.opacity(0.2))
                .frame(maxHeight: 2)
        }
    }
    
    private func cellBackgroundColor(for index: Int) -> Color {
        return index.isOdd ? .secondary.opacity(0.1) : .clear
    }
}

// MARK: - Methods
private extension RecipeGuideFeature {
    func onAppear() {
        state.synchronize(recipe)
    }
    
    func fetchRecipeDetails() {
        guard state.ingredients.isEmpty, state.sources.isEmpty, state.detailedSteps.isEmpty else { return }
        
        state.cancelTask(for: #function)
        
        let task = Task {
            do {
                let recipeDetails = try await recipeRepository.read(recipeID: recipe.id)
                state.synchronize(recipeDetails)
                recipe.ingredients = recipeDetails.ingredients
                recipe.sources = recipeDetails.sources
                recipe.detailedSteps = recipeDetails.detailedSteps
            } catch {
                let item = FloaterItem(role: .warning, message: FloaterMessageNamespace.unknownErrorOccurred.message)
                state.floaterItem = item
            }
        }
        
        state.storeTask(for: #function, task: task)
    }
}

#Preview {
    RecipeGuideFeature(recipe: PreviewHelper.shared.mockRecipe)
}

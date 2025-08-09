//
//  RecipeDetailView.swift
//  RecipeForT
//
//  Created by Swain Yun on 6/10/25.
//

import SwiftUI
import Swinject

struct RecipeGuideView: View {
    @EnvironmentObject private var router: Router
    @State private var viewer: RecipeViewer
    
    private let recipe: Recipe
    
    init(recipe: Recipe, resolver: Resolver) {
        self.recipe = recipe
        viewer = RecipeViewer(recipe)
    }
    
    var body: some View {
        ScrollView(.vertical) {
            RecipeInformationSection(recipe: recipe)
            
            thickDivider
            
            IngredientSection(viewer: viewer)
            
            thickDivider
            
            DetailedStepsSection(steps: recipe.detailedSteps)
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
}

// MARK: - Subviews
extension RecipeGuideView {
    struct RecipeInformationSection: View {
        let recipe: Recipe
        
        var body: some View {
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
                
                // TODO: 레시피 작성자 정보 비동기로 가져오기
                Text("홍길동")
                    .foregroundStyle(.gray)
                
                Text(recipe.description)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.gray)
            }
        }
    }
    
    struct IngredientSection: View {
        @Bindable var viewer: RecipeViewer
        
        var body: some View {
            VStack(spacing: 12) {
                Text("Ingredients")
                    .font(.title3.bold())
                
                if let servings = viewer.servings {
                    HStack(spacing: 12) {
                        Button {
                            viewer.decreaseServing()
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
                            viewer.increaseServing()
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
                            ForEach(viewer.ingredients.indices, id: \.self) { index in
                                cell(viewer.ingredients[index])
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
                            ForEach(viewer.sources.indices, id: \.self) { index in
                                cell(viewer.sources[index])
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
        
        private func cellBackgroundColor(for index: Int) -> Color {
            return index.isOdd ? .secondary.opacity(0.1) : .clear
        }
    }
    
    struct DetailedStepsSection: View {
        let steps: [CookingStep]
        
        var body: some View {
            LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                ForEach(steps) { step in
                    stepView(step)
                    
                    thickDivider
                }
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
        
        private var thickDivider: some View {
            Rectangle()
                .fill(.gray.opacity(0.3))
                .padding(.vertical)
        }
    }
}

#Preview {
    NavigationStack {
        RecipeGuideView(recipe: PreviewHelper.shared.mockRecipe, resolver: PreviewHelper.shared.resolver)
            .environmentObject(PreviewHelper.shared.router)
    }
}

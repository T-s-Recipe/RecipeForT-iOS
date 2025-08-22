//
//  EditRecipeFeature.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/12/25.
//

import SwiftUI

@MainActor
struct EditRecipeFeature {
    @Environment(\.router) private var router
    @Environment(\.memberRepository) private var memberRepository
    @Environment(\.recipeRepository) private var recipeRepository
    @State private var state: EditRecipeState
    
    init(recipe: Recipe?) {
        state = EditRecipeState(recipe: recipe)
    }
}

// MARK: - ViewFeature Conformation
extension EditRecipeFeature: ViewFeature {
    enum UIEvent {
        case toggleMustReadSheet
        case submitRecipe
        case dismiss
    }
    
    func notify(_ event: UIEvent) {
        switch event {
        case .toggleMustReadSheet:
            state.isMustReadSheetPresented.toggle()
        case .submitRecipe:
            uploadRecipe()
        case .dismiss:
            router.dismiss()
        }
    }
}

// MARK: - View Conformation
extension EditRecipeFeature: View {
    var body: some View {
        VStack {
            navigationHeader
            
            ScrollView(.vertical) {
                LazyVStack {
                    RecipeBaseInfoFeature(state: state)
                    
                    thickDivider
                    
                    RecipeIngredientsInfoFeature(state: state)
                    
                    thickDivider
                    
                    RecipeDetailedStepInfoFeature(state: state)
                }
            }
        }
        .fullScreenCover(isPresented: $state.isMustReadSheetPresented) {
            MustReadSheet()
        }
        .floater($state.floaterItem)
    }
    
    @ViewBuilder private var navigationHeader: some View {
        HStack {
            Button {
                notify(.dismiss)
            } label: {
                Image(systemName: "xmark")
            }
            .tint(.black)
            
            Spacer()
            
            HStack(spacing: 4) {
                Text("Recipe")
                
                Button {
                    notify(.toggleMustReadSheet)
                } label: {
                    Image(systemName: "info.circle")
                }
                .tint(.black)
            }
            
            Spacer()
            
            Button {
                notify(.submitRecipe)
            } label: {
                if state.isLoading {
                    ProgressView()
                } else {
                    Text("등록")
                }
            }
            .tint(.black)
            .disabled(state.isLoading)
        }
        .padding()
        
        Divider()
    }
    
    private var thickDivider: some View {
        Rectangle()
            .frame(height: 10)
            .foregroundStyle(.gray.opacity(0.3))
    }
}

// MARK: - Methods
private extension EditRecipeFeature {
    func uploadRecipe() {
        state.cancelTask(for: #function)
        
        let task = Task {
            state.isLoading = true
            defer { state.isLoading = false }
            
            let usecase = RecipeUploadUseCase(memberRepository: memberRepository, recipeRepository: recipeRepository)
            
            do {
                try await usecase.execute(
                    state.title,
                    state.image,
                    servings: Decimal(string: state.servings),
                    cost: Decimal(string: state.cost),
                    cookingTime: Decimal(string: state.time),
                    notes: state.notes,
                    basicIngredients: state.ingredients,
                    sources: state.sources,
                    detailedSteps: state.steps
                )
                
                router.dismiss()
            } catch {
                state.floaterItem = FloaterItem(role: .warning, message: FloaterMessageNamespace.unknownErrorOccurred)
            }
        }
        
        state.storeTask(for: #function, task: task)
    }
}


// MARK: - Subviews
extension EditRecipeFeature {
    struct MustReadSheet: View {
        @Environment(\.dismiss) private var dismiss
        
        var body: some View {
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .tint(.black)
                    
                    Spacer()
                    
                    Text("Must read")
                    
                    Spacer()
                }
                .padding()
                
                Divider()
                
                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Sauce mixing order")
                            .font(.headline)
                        
                        Text("When writing out detailed recipe steps, please follow this order:")
                            .bulletPoint()
                        
                        Text("List the ingredients starting with those that don't stick to the spoon, followed by those that do. (e.g. sugar, salt -> honey, soy sauce")
                            .bulletPoint()
                        
                        Text("Measurement units")
                            .font(.headline)
                        
                        Text("1T: 1 tablespoon")
                            .bulletPoint()
                        
                        Text("1t: 1 teaspoon")
                            .bulletPoint()
                        
                        Text("Recipe")
                            .font(.headline)
                        
                        Text("When writing a recipe, avoid writing long sentences. Break them down into shorter steps as much as possible.")
                            .bulletPoint()
                    }
                    .padding(16)
                }
            }
        }
    }
}

#Preview {
    EditRecipeFeature(recipe: nil)
}

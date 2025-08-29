//
//  EditRecipeFeature.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/12/25.
//

import SwiftUI

@MainActor
struct EditRecipeFeature {
    typealias MissingField = EditRecipeState.MissingField
    
    @Environment(\.router) private var router
    @Environment(MemberModel.self) private var memberModel
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
            
            ScrollViewReader { proxy in
                ScrollView(.vertical) {
                    LazyVStack {
                        RecipeBaseInfoFeature(state: state)
                            .id(MissingField.image.scrollTargetID)
                        
                        thickDivider
                        
                        RecipeIngredientsInfoFeature(state: state)
                            .id(MissingField.ingredients.scrollTargetID)
                        
                        thickDivider
                        
                        RecipeDetailedStepInfoFeature(state: state)
                            .id(MissingField.steps.scrollTargetID)
                    }
                }
                .onChange(of: state.missingField) { _, newValue in
                    guard let newValue else { return }
                    scrollToMissingField(newValue, using: proxy)
                }
            }
        }
        .fullScreenCover(isPresented: $state.isMustReadSheetPresented) {
            MustReadSheet()
        }
        .floater($state.floaterItem)
        .focusable()
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
                    Text("OK")
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
    func scrollToMissingField(_ field: MissingField, using proxy: ScrollViewProxy) {
        withAnimation {
            proxy.scrollTo(field.scrollTargetID, anchor: .center)
        }
        state.missingField = nil
    }
    
    func checkRequiredFields() -> Bool {
        guard state.image != nil else {
            let item = FloaterItem(role: .warning, message: FloaterMessageNamespace.missingRequiredFields(which: "Image").message)
            state.floaterItem = item
            state.missingField = .image
            return false
        }
        
        guard state.title.isEmpty == false else {
            let item = FloaterItem(role: .warning, message: FloaterMessageNamespace.missingRequiredFields(which: "Title").message)
            state.floaterItem = item
            state.missingField = .title
            return false
        }
        
        guard state.ingredients.isEmpty == false else {
            let item = FloaterItem(role: .warning, message: FloaterMessageNamespace.missingRequiredFields(which: "Ingredient").message)
            state.floaterItem = item
            state.missingField = .ingredients
            return false
        }
        
        guard state.steps.isEmpty == false else {
            let item = FloaterItem(role: .warning, message: FloaterMessageNamespace.missingRequiredFields(which: "Step").message)
            state.floaterItem = item
            state.missingField = .steps
            return false
        }
        
        return true
    }
    
    func uploadRecipe() {
        state.cancelTask(for: #function)
        
        guard checkRequiredFields() else { return }
        
        let task = Task {
            state.isLoading = true
            defer { state.isLoading = false }
            
            guard let member = memberModel.user else { return router.route(to: .loginView) }
            
            do {
                _ = try await recipeRepository.create(
                    userID: member.id,
                    title: state.title,
                    image: state.image,
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
                state.floaterItem = FloaterItem(role: .warning, message: FloaterMessageNamespace.unknownErrorOccurred.message)
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

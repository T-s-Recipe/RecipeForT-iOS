//
//  RecipeDetailView.swift
//  RecipeForT
//
//  Created by Swain Yun on 6/10/25.
//

import SwiftUI

struct RecipeGuideView: View {
    @EnvironmentObject private var router: Router
    
    let recipe: Recipe
    
    var body: some View {
        ScrollView(.vertical) {
            RecipeInformationSection(recipe: recipe)
            
            Rectangle()
                .fill(.gray.opacity(0.3))
                .padding(.vertical)
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
        var body: some View {
            
        }
    }
}

#Preview {
    NavigationStack {
        RecipeGuideView(recipe: PreviewHelper.shared.mockRecipe)
            .environmentObject(PreviewHelper.shared.router)
    }
}

/*
 HStack(spacing: 12) {
     Button {
         viewModel.decreaseServingsCount()
     } label: {
         Image(systemName: "minus")
     }
     .background(
         Circle()
             .fill(.gray.opacity(0.3))
             .frame(width: 24, height: 24)
     )
     .tint(.black)
     
     Text("\(viewModel.servings) \(viewModel.servings > 1 ? "Servings" : "Serving")")
         .monospacedDigit()

     Button {
         viewModel.increaseServingsCount()
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
 */

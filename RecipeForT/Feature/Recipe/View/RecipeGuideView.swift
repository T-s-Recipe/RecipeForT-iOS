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
        }
        .toolbar {
//            ToolbarItem(placement: .topBarLeading) {
//                Button {
//                    
//                } label: {
//                    Image(systemName: "arrow.left")
//                }
//            }
        }
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
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
                
                Text(recipe.title)
                    .font(.title3)
                
                HStack(spacing: 8) {
                    Text("\(recipe.servingsCount)인분")
                    
                    Circle()
                        .frame(width: 4, height: 4)
                    
                    Text("\(recipe.cost)원")
                    
                    Circle()
                        .frame(width: 4, height: 4)
                    
                    Text("\(recipe.cookingTime)분")
                }
                
                Text(recipe.ownerName)
                
                Text(recipe.additionalInformation)
                    .multilineTextAlignment(.center)
                
                Button {
                    // TODO: 필독! 버튼
                } label: {
                    Text("필독!")
                        .font(.headline)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 24)
                }
                .buttonStyle(.roundedProminent(
                    background: .black
                ))
            }
        }
    }
}

#Preview {
    NavigationStack {
        RecipeGuideView(recipe: .mock())
    }
}

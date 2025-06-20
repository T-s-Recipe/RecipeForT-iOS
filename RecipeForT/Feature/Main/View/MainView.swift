//
//  MainView.swift
//  RecipeForT
//
//  Created by Swain Yun on 6/8/25.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject private var router: Router
    
    @State private var recipes: [Recipe] = []
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 12) {
                ForEach(recipes) { recipe in
                    Cell(recipe: recipe)
                }
            }
        }
    }
}

// MARK: - Subviews
extension MainView {
    struct Header: View {
        @State private var searchText = String()
        
        private let prompt: Text = Text("레시피 검색")
        
        var body: some View {
            HStack {
                Image(systemName: "house")
                
                Spacer()
                
                TextField("레시피 검색", text: $searchText, prompt: prompt)
            }
            .padding()
        }
    }
    
    struct Cell: View {
        @EnvironmentObject private var router: Router
        
        let recipe: Recipe
        
        var body: some View {
            VStack {
                AsyncImage(url: recipe.imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(1.6, contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(.gray.opacity(0.3))
                        .aspectRatio(1.6, contentMode: .fill)
                }
                
                HStack{
                    VStack(alignment: .leading, spacing: 4) {
                        Text(recipe.name)
                        
                        HStack(spacing: 8) {
                            Text("\(recipe.servingsCount)인분")
                            
                            Circle()
                                .frame(width: 4, height: 4)
                            
                            Text("\(recipe.cost)원")
                            
                            Circle()
                                .frame(width: 4, height: 4)
                            
                            Text("\(recipe.cookingTime)분")
                        }
                        
//                        Text(recipe.authorID)
                    }
                    
                    Spacer()
                }
                .padding(16)
            }
            .clipShape(.rect)
            .onTapGesture {
                router.route(to: .recipeGuideView(recipe))
            }
        }
    }
}

#Preview {
    MainView()
        .environmentObject(Router())
}

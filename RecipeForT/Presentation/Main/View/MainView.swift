//
//  MainView.swift
//  RecipeForT
//
//  Created by Swain Yun on 6/8/25.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject private var router: Router
    
    @State private var recipes: [Recipe] = [
        PreviewHelper.shared.mockRecipe
    ]
    
    private let column: [GridItem] = [
        .init(.adaptive(minimum: 120, maximum: .infinity)),
        .init(.adaptive(minimum: 120, maximum: .infinity))
    ]
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: column, spacing: 8) {
                ForEach(recipes) { recipe in
                    Cell(recipe: recipe)
                }
            }
            .padding(.horizontal)
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
                        
                        HStack(spacing: 8) {
                            Text("\(recipe.servingsCount)serv")
                            
                            Circle()
                                .frame(width: 4, height: 4)
                            
                            Text("$\(recipe.cost)")
                            
                            Circle()
                                .frame(width: 4, height: 4)
                            
                            Text("\(recipe.cookingTime)min")
                        }
                        .font(.subheadline)
                        
                        Text("Author Name")
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

#Preview {
    ContentView()
}

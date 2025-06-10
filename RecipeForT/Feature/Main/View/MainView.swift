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
        .init(id: 0, title: "브로콜리 두부 무침", imageURL: nil, servingsCount: 3, cost: 4000, cookingTime: 15, ownerName: "홍길동", additionalInformation: "부가설명"),
        .init(id: 1, title: "김치찌개", imageURL: nil, servingsCount: 4, cost: 3000, cookingTime: 20, ownerName: "김영희", additionalInformation: "부가설명"),
        .init(id: 2, title: "소고기 볶음밥", imageURL: nil, servingsCount: 2, cost: 5000, cookingTime: 30, ownerName: "이영수", additionalInformation: "부가설명"),
        .init(id: 3, title: "오이소박이", imageURL: nil, servingsCount: 1, cost: 2000, cookingTime: 10, ownerName: "최민영", additionalInformation: "부가설명"),
    ]
    
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
                        Text(recipe.title)
                        
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

//
//  MainView.swift
//  RecipeForT
//
//  Created by Swain Yun on 6/8/25.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        VStack {
            Header()
            
            ZStack(alignment: .bottom) {
                ScrollView(.vertical) {
                    LazyVStack(spacing: 50) {
                        ForEach(0..<10, id: \.self) { number in
                            Cell(imageURL: nil, title: "\(number)")
                        }
                    }
                }
                
                Button {
                    
                } label: {
                    Text("메뉴 요청")
                        .padding()
                }
                .buttonStyle(.roundedProminent())
            }
        }
        .padding(.horizontal)
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
        let imageURL: URL?
        let title: String
        
        var body: some View {
            VStack {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .frame(width: .infinity, height: 180)
                        .clipShape(.buttonBorder)
                }
                

                Text(title)
            }
        }
    }
}

#Preview {
    MainView()
}

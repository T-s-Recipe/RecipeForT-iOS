//
//  SearchFeature.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/12/25.
//

import SwiftUI

@MainActor
struct SearchFeature {
    @Environment(\.router) private var router
    @Environment(\.recipeRepository) private var recipeRepository
    @State private var state = SearchState()
    
    private let columns: [GridItem] = [
        .init(.adaptive(minimum: 120, maximum: .infinity)),
        .init(.adaptive(minimum: 120, maximum: .infinity))
    ]
}

// MARK: - ViewFeature Conformation
extension SearchFeature: ViewFeature {
    enum UIEvent {
        case task
        case submit(String)
    }
    
    func notify(_ event: UIEvent) {
        switch event {
        case .task:
            break
        case .submit(let keyword):
            fetchSearchResults(keyword)
        }
    }
}

// MARK: - View Conformation
extension SearchFeature: View {
    var body: some View {
        VStack {
            SearchBar(text: $state.searchingText) {
                notify(.submit(state.searchingText))
            }
            
            ScrollView(.vertical) {
                switch state.entity {
                case .initial:
                    EmptyView()
                case .loading:
                    ProgressView()
                case .loaded(let recipes):
                    LazyVGrid(columns: columns) {
                        ForEach(recipes) { recipe in
                            recipeCell(recipe)
                        }
                    }
                case .notFound:
                    unavailableView
                }
            }
        }
        .task {
            notify(.task)
        }
    }
    
    @ViewBuilder private func recipeCell(_ recipe: Recipe) -> some View {
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
                    
                    if let servingsCount = recipe.servingsCount,
                       let cost = recipe.cost,
                       let cookingTime = recipe.cookingTime {
                        HStack(spacing: 8) {
                            Text("\(servingsCount)serv")
                            
                            Circle()
                                .frame(width: 4, height: 4)
                            
                            Text("$\(cost)")
                            
                            Circle()
                                .frame(width: 4, height: 4)
                            
                            Text("\(cookingTime)min")
                        }
                        .font(.subheadline)
                    }
                    
                    Text(recipe.authorNickname)
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
    
    private var unavailableView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "exclamationmark.magnifyingglass")
                .resizable()
                .frame(width: 52, height: 52)
                .foregroundStyle(.gray)
            
            Text("No Result Found")
                .fontWeight(.bold)
            
            Text("Can't find what you're looking for?\nJust let us know and we'll add it for you!")
                .multilineTextAlignment(.center)
                .foregroundStyle(.gray)
            
            Button {
                // TODO: 무슨 비즈니스를 수행하는지 확인 필요
            } label: {
                Text("Request this recipe!")
            }
            .buttonStyle(.borderedProminent)
            .tint(.black)
            
            Spacer()
        }
    }
}

// MARK: - Methods
private extension SearchFeature {
    func fetchSearchResults(_ keyword: String) {
        state.cancelTask(for: #function)
        
        let task = Task {
            // TODO: 레시피 검색 기능 추가
        }
        
        state.storeTask(for: #function, task: task)
    }
}

// MARK: - Subviews
extension SearchFeature {
    struct SearchBar: View {
        @Binding var text: String
        @FocusState private var isFocused: Bool
        
        let onSubmit: () -> Void
        
        var body: some View {
            HStack {
                HStack {
                    TextField("Search Keywords", text: $text)
                        .focused($isFocused)
                        .submitLabel(.search)
                        .onSubmit(onSubmit)
                        
                    if text.isEmpty == false {
                        Button {
                            removeText()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                        }
                        .tint(.gray.opacity(0.3))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.clear)
                        .strokeBorder(isFocused ? .black : .gray.opacity(0.3))
                )
                
                if isFocused {
                    Button {
                        removeText()
                        releaseFocus()
                    } label: {
                        Text("Cancel")
                    }
                    .tint(.black)
                    .transition(.push(from: .leading))
                }
            }
            .animation(.smooth, value: isFocused)
            .padding()
        }
        
        private func removeText() {
            text.removeAll()
        }
        
        private func releaseFocus() {
            isFocused = false
        }
    }
}

#Preview {
    SearchFeature()
}

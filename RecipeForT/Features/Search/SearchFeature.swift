//
//  SearchFeature.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/12/25.
//

import SwiftUI

@MainActor
struct SearchFeature {
    @State private var state = SearchState()
}

// MARK: - ViewFeature Conformation
extension SearchFeature: ViewFeature {
    enum UIEvent {
        case task
        case submit(String)
    }
    
    func notify(_ event: UIEvent) {
        
    }
}

// MARK: - View Conformation
extension SearchFeature: View {
    var body: some View {
        VStack {
            SearchBar(text: $state.searchingText) {
                notify(.submit(state.searchingText))
            }
            
            switch state.entity {
            case .initial:
                EmptyView()
                
            case .notFound:
                unavailableView
                
            case .found(let recipes):
                ScrollView(.vertical) {
                    Text("WIP")
                }
            }
        }
        .task {
            notify(.task)
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

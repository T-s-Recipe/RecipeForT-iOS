//
//  SearchingView.swift
//  RecipeForT
//
//  Created by Swain Yun on 6/30/25.
//

import SwiftUI

struct SearchingView: View {
    @State private var searchText: String = String()
    
    var body: some View {
        VStack {
            SearchBar(text: $searchText) {
                print("OnSubmitted")
            }
            
            ScrollView(.vertical) {
                Text("WIP")
            }
            .border(.red)
        }
    }
}

// MARK: - Subviews
extension SearchingView {
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
    SearchingView()
}

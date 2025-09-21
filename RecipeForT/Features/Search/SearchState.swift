//
//  SearchState.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/12/25.
//

import Foundation

@MainActor @Observable
final class SearchState: ViewState {
    enum Entity {
        case loading
        case loaded(recipes: [Recipe])
        case notFound
    }
    
    var entity: Entity = .loaded(recipes: [])
    var searchingText: String = ""
    var tasks: [String: Task<Void, Never>] = [:]
}

// MARK: - Interfaces
extension SearchState {
    
}

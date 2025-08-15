//
//  SearchState.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/12/25.
//

import Foundation

@MainActor @Observable
final class SearchState {
    enum Entity {
        case initial
        case loading
        case loaded(recipes: [Recipe])
        case notFound
    }
    
    var entity: Entity = .initial
    var searchingText: String = ""
    private var tasks: [String: Task<Void, Never>] = [:]
}

// MARK: - Interfaces
extension SearchState {
    func cancelTask(for key: String) {
        tasks[key]?.cancel()
    }
    
    func storeTask(for key: String, task: Task<Void, Never>) {
        tasks[key] = task
    }
}

//
//  RecipeListState.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/12/25.
//

import Foundation

@MainActor @Observable
final class RecipeListState {
    var recipes: [Recipe] = []
    var floaterItem: FloaterItem?
    var isLoading: Bool = false
    var nextPageID: String?
    let fetchLimit: Int32 = 16
    
    private var tasks: [String: Task<Void, Never>] = [:]
}

// MARK: - Interfaces
extension RecipeListState {
    func cancelTask(for key: String) {
        tasks[key]?.cancel()
    }
    
    func storeTask(for key: String, task: Task<Void, Never>) {
        tasks[key] = task
    }
    
    func flush() {
        recipes.removeAll()
        nextPageID = nil
    }
}

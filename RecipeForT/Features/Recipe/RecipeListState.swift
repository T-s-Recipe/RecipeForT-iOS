//
//  RecipeListState.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/12/25.
//

import Foundation

@MainActor @Observable
final class RecipeListState: ViewState {
    var recipes: [Recipe] = []
    var floaterItem: FloaterItem?
    var isErrorOccurred: Bool = false
    var isLoading: Bool = false
    var nextPageID: String?
    var isRefreshNeeded: Bool = true
    let fetchLimit: Int32 = 16
    
    var tasks: [String: Task<Void, Never>] = [:]
}

// MARK: - Interfaces
extension RecipeListState {
    func flush() {
        recipes.removeAll()
        nextPageID = nil
    }
}

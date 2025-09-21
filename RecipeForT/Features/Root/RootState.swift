//
//  RootState.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/11/25.
//

import Foundation

@Observable @MainActor
final class RootState {
    enum TabSelection: Hashable {
        case main, search, recipeUpload, preferences
    }
    
    var currentTab: TabSelection = .main
    @ObservationIgnored var previousTab: TabSelection = .main
    
    func updateTab(to newTab: TabSelection) {
        previousTab = currentTab
        currentTab = newTab
    }
    
    func backToPreviousTab() {
        currentTab = previousTab
    }
}

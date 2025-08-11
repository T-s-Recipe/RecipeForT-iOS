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
        case notFound
        case found([Recipe])
    }
    
    var entity: Entity = .initial
    var searchingText: String = ""
}

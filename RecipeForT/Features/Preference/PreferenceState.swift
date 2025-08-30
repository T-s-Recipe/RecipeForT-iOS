//
//  PreferenceState.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/18/25.
//

import Foundation

@MainActor @Observable
final class PreferenceState: ViewState {
    var inquiries: [Inquiry] = []
    var announcements: [Announcement] = []
    var floaterItem: FloaterItem?
    
    var tasks: [String: Task<Void, Never>] = [:]
}

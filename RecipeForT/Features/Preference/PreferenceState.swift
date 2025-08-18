//
//  PreferenceState.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/18/25.
//

import Foundation

@MainActor @Observable
final class PreferenceState {
    var user: Member?
    var inquiries: [Inquiry] = []
    var announcements: [Announcement] = []
}

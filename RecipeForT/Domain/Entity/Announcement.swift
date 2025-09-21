//
//  Announcement.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/18/25.
//

import Foundation

protocol AnnouncementContent: Identifiable {
    var id: String { get }
    var content: String { get }
    var createdAt: Date { get }
}

struct Announcement: AnnouncementContent {
    let id: String
    let content: String
    let createdAt: Date
}

struct Inquiry: AnnouncementContent {
    let id: String
    let content: String
    let createdAt: Date
    let answer: String?
}

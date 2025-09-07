//
//  Announcement.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/18/25.
//

import Foundation

struct Announcement {
    let id: String
    let content: String
    let createdAt: Date
}

struct Inquiry {
    let id: String
    let content: String
    let createdAt: Date
    let answer: String?
}

enum AnnouncementItem: Equatable, Identifiable {
    case notice(Announcement)
    case inquiry(Inquiry)
    
    var id: String {
        switch self {
        case .notice(let notice): notice.id
        case .inquiry(let inquiry): inquiry.id
        }
    }
    
    var content: String {
        switch self {
        case .notice(let notice): notice.content
        case .inquiry(let inquiry): inquiry.content
        }
    }
    
    var createdAt: Date {
        switch self {
        case .notice(let notice): notice.createdAt
        case .inquiry(let inquiry): inquiry.createdAt
        }
    }
    
    var answer: String? {
        guard case .inquiry(let inquiry) = self else { return nil }
        return inquiry.answer
    }
    
    static func == (lhs: AnnouncementItem, rhs: AnnouncementItem) -> Bool {
        lhs.id == rhs.id
    }
}

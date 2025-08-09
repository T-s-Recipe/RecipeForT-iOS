//
//  StepDTO.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/9/25.
//

import Foundation

struct StepDTO: Codable {
    let title: String
    let process: [Process]
    
    init(title: String, process: [Process]) {
        self.title = title
        self.process = process
    }
    
    init(title: String, process: [CookingDetailedProcess]) {
        self.title = title
        self.process = process.map { .init(content: $0.description) }
    }
    
    func toEntity() -> CookingStep {
        let processes: [CookingDetailedProcess] = process.map { .init(description: $0.content) }
        return .init(title: title, detailedProcesses: processes)
    }
}

extension StepDTO {
    struct Process: Codable {
        let content: String
    }
}

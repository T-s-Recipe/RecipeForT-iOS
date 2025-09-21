//
//  ViewState.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/15/25.
//

import Foundation

@MainActor
protocol ViewState: AnyObject {
    associatedtype TaskKey: Hashable
    
    var tasks: [TaskKey: Task<Void, Never>] { get set }
    
    func cancelTask(for key: TaskKey)
    func storeTask(for key: TaskKey, task: Task<Void, Never>)
    func cancelAllTasks()
}

extension ViewState {
    func cancelTask(for key: TaskKey) {
        tasks[key]?.cancel()
    }
    
    func storeTask(for key: TaskKey, task: Task<Void, Never>) {
        tasks[key] = task
    }
    
    func cancelAllTasks() {
        tasks.values.forEach { $0.cancel() }
        tasks.removeAll()
    }
}

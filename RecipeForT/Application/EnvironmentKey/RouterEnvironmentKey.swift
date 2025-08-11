//
//  RouterEnvironmentKey.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/11/25.
//

import SwiftUI

private struct RouterEnvironmentKey: EnvironmentKey {
    typealias Value = Router
    
    static var defaultValue: Value = Router()
}

extension EnvironmentValues {
    var router: Router {
        get { self[RouterEnvironmentKey.self] }
        set { self[RouterEnvironmentKey.self] = newValue }
    }
}

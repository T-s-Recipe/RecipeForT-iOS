//
//  FloaterMessageNamespace.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/5/25.
//

import Foundation

enum FloaterMessageNamespace {
    case unknownErrorOccurred
    case authenticationNotCompleted
    case loggedOut
    case accountCreated
    case missingRequiredFields(which: String)
    
    var message: String {
        switch self {
        case .unknownErrorOccurred: "Please try again in a moment."
        case .authenticationNotCompleted: "Authentication not completed."
        case .loggedOut: "You've been logged out."
        case .accountCreated: "Your account has been successfully created!"
        case .missingRequiredFields(let which): "Missing required fields: \(which)."
        }
    }
}

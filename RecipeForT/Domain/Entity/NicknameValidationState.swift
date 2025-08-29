//
//  NicknameValidationState.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/28/25.
//

import Foundation

enum NicknameValidationState {
    case valid
    case duplicated
    case limitExceeded
    case emptyNickname
    
    var isError: Bool { self != .valid }
}

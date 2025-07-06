//
//  Date.swift
//  RecipeForT
//
//  Created by Swain Yun on 7/6/25.
//

import Foundation

// MARK: - Date+DateFormat
extension Date {
    func toString(by dateFormat: DateFormat) -> String {
        let formatter = DateFormat.cachedFormatter(dateFormat: dateFormat)
        return formatter.string(from: self)
    }
    
    /// DateFormat에서 제공하는 형태와 다른 날짜 형식일 경우 사용
    func toString(by dateFormat: String) -> String {
        let formatter = DateFormat.cachedFormatter(dateFormat: dateFormat)
        return formatter.string(from: self)
    }
}

//
//  Number.swift
//  RecipeForT
//
//  Created by Swain Yun on 7/29/25.
//

import Foundation

// MARK: - Int + Common
extension Int {
    var isEven: Bool { self % 2 == 0 }
    
    var isOdd: Bool { isEven == false }
}

// MARK: - Decimal + Common
extension Decimal {
    func rounded(to places: Int16) -> Decimal {
        let behavior = NSDecimalNumberHandler(
            roundingMode: .plain,
            scale: places,
            raiseOnExactness: false,
            raiseOnOverflow: false,
            raiseOnUnderflow: false,
            raiseOnDivideByZero: false
        )
        return (self as NSDecimalNumber).rounding(accordingToBehavior: behavior) as Decimal
    }
}

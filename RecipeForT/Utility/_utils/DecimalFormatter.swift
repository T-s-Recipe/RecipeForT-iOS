//
//  DecimalFormatter.swift
//  RecipeForT
//
//  Created by Swain Yun on 7/4/25.
//

import Foundation

final class DecimalFormatter: NumberFormatter, @unchecked Sendable {
    override init() {
        super.init()
        self.numberStyle = .decimal
        self.minimumFractionDigits = 0
        self.maximumFractionDigits = 2
        self.usesGroupingSeparator = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

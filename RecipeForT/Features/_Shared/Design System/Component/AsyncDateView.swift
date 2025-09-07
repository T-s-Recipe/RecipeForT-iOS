//
//  AsyncDateView.swift
//  RecipeForT
//
//  Created by Swain Yun on 9/7/25.
//

import SwiftUI

struct AsyncDateView: View {
    @State private var text: String = String()
    private let date: Date
    private let format: DateFormat
    
    init(date: Date, format: DateFormat) {
        self.date = date
        self.format = format
    }
    
    var body: some View {
        Text(text)
            .task {
                text = await date.toString(by: format)
            }
    }
}

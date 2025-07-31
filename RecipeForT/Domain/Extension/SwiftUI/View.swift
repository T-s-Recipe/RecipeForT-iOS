//
//  View.swift
//  RecipeForT
//
//  Created by Swain Yun on 7/1/25.
//

import SwiftUI

// MARK: - View + Floater
extension View {
    func floater(
        _ isPresented: Binding<Bool>,
        role: FloaterModifier.Role = .normal,
        message: String
    ) -> some View {
        modifier(FloaterModifier(isPresented, role: role, message: message))
    }
    
    func floater(_ item: Binding<FloaterItem?>) -> some View {
        modifier(FloaterModifier(item: item))
    }
}

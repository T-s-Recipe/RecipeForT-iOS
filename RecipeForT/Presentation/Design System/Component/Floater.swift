//
//  Floater.swift
//  RecipeForT
//
//  Created by Swain Yun on 7/1/25.
//

import SwiftUI

struct FloaterItem {
    enum Role {
        case normal
        case warning
    }
    
    let role: Role
    let message: String
    
    init(role: Role = .normal, message: String) {
        self.role = role
        self.message = message
    }
}

// MARK: - Equatable Conformation
extension FloaterItem: Equatable {
    
}

struct FloaterModifier: ViewModifier {
    typealias Role = FloaterItem.Role
    
    @Binding var isPresented: Bool
    
    let role: Role
    let message: String
    
    init(
        _ isPresented: Binding<Bool>,
        role: Role = .normal,
        message: String
    ) {
        self._isPresented = isPresented
        self.role = role
        self.message = message
    }
    
    init(item: Binding<FloaterItem?>) {
        self._isPresented = Binding(
            get: { item.wrappedValue != nil },
            set: { if !$0 { item.wrappedValue = nil } }
        )
        self.role = item.wrappedValue?.role ?? .normal
        self.message = item.wrappedValue?.message ?? ""
    }
    
    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content
            
            if isPresented {
                HStack(spacing: 10) {
                    Text(message)
                        .frame(maxWidth: .infinity)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                    
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                .padding()
                .background(
                    Rectangle()
                        .fill(role == .normal ? .cyan.opacity(0.3) : .pink.opacity(0.3))
                        .strokeBorder(role == .normal ? .cyan : .pink)
                )
                .transition(.push(from: .bottom))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        isPresented = false
                    }
                }
                .safeAreaPadding(.bottom)
            }
        }
        .animation(.smooth, value: isPresented)
    }
}

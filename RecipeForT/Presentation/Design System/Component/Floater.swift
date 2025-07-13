//
//  Floater.swift
//  RecipeForT
//
//  Created by Swain Yun on 7/1/25.
//

import SwiftUI

struct FloaterModifier: ViewModifier {
    enum Role {
        case normal
        case warning
    }
    
    @Binding var isPresented: Bool
    
    let role: Role
    let message: Text
    
    init(
        _ isPresented: Binding<Bool>,
        role: Role = .normal,
        message: any StringProtocol
    ) {
        self._isPresented = isPresented
        self.role = role
        self.message = Text(message)
    }
    
    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content
            
            if isPresented {
                HStack(spacing: 10) {
                    message
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
            }
        }
        .animation(.smooth, value: isPresented)
    }
}

//
//  AuthFeature.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/11/25.
//

import SwiftUI

struct AuthFeature {
    enum Constants: String, CustomStringConvertible {
        case title = "Log in"
        case subtitle = "Welcome back !"
        
        var description: String { self.rawValue }
    }
    
    @Environment(\.router) private var router
    @Environment(\.memberRepository) private var memberRepository
    
    private var isPendingRegistration: Bool {
        memberRepository.authenticationState.isRegistrationNeeded
    }
}

// MARK: - ViewFeature Conformation
extension AuthFeature: ViewFeature {
    enum UIEvent {
        
    }
    
    func notify(_ event: UIEvent) {
        
    }
}

// MARK: - View Conformation
extension AuthFeature: View {
    var body: some View {
        VStack {
            VStack(spacing: 8) {
                Text(Constants.title.description)
                    .font(.title.weight(.medium))
                
                Text(Constants.subtitle.description)
            }
            .safeAreaPadding(.top, 98)
            
            Spacer()
            
            VStack(spacing: 12) {
                if isPendingRegistration {
                    SignUpFeature()
                } else {
                    SignInFeature()
                }
            }
            .padding(.horizontal)
            
            Spacer()
            Spacer()
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton(.xmark)
            }
        }
    }
}

#Preview {
    AuthFeature()
}

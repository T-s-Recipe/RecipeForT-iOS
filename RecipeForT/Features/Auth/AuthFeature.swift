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
    
    @State private var isPendingRegistration: Bool = false
}

// MARK: - ViewFeature Conformation
extension AuthFeature: ViewFeature {
    enum UIEvent {
        case onAppear
    }
    
    func notify(_ event: UIEvent) {
        switch event {
        case .onAppear:
            isPendingRegistration = memberRepository.authenticationState.isRegistrationNeeded
        }
    }
}

// MARK: - View Conformation
extension AuthFeature: View {
    var body: some View {
        VStack {
            HStack {
                BackButton(.xmark)
                
                Spacer()
            }
            .padding(.horizontal)
            
            VStack(spacing: 8) {
                Text(Constants.title.description)
                    .font(.title.weight(.medium))
                
                Text(Constants.subtitle.description)
            }
            .safeAreaPadding(.top, 98)
            
            Spacer()
            
            VStack(spacing: 12) {
                if isPendingRegistration {
                    SignUpFeature(isPendingRegistration: $isPendingRegistration)
                } else {
                    SignInFeature(isPendingRegistration: $isPendingRegistration)
                }
            }
            .padding(.horizontal)
            
            Spacer()
            Spacer()
        }
        .onAppear {
            notify(.onAppear)
        }
    }
}

#Preview {
    AuthFeature()
}

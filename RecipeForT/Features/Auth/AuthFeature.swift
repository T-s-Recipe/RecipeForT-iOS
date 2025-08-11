//
//  AuthFeature.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/11/25.
//

import SwiftUI
import AuthenticationServices
import GoogleSignIn
import Swinject

struct AuthFeature {
    enum Entity: Equatable {
        case loading
        case loaded(AuthenticationState)
        case error(FloaterItem)
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.loading, .loading):
                return true
            case (.loaded(let lhsValue), .loaded(let rhsValue)):
                return lhsValue == rhsValue
            case (.error(let lhsValue), .error(let rhsValue)):
                return lhsValue == rhsValue
            default:
                return false
            }
        }
    }
    
    @Environment(\.router) private var router
    @Environment(\.memberRepository) private var memberRepository
    @State private var entity: Entity = .loaded(.loggedOut)
}

// MARK: - ViewFeature Conformation
extension AuthFeature: ViewFeature {
    enum UIEvent {
        case task
        case signInWithGoogle(result: Result<GIDSignInResult, Error>)
        case signInWithApple(result: Result<ASAuthorizationResult, Error>)
        case floater(item: FloaterItem)
    }
    
    func notify(_ event: UIEvent) {
        switch event {
        case .task:
            <#code#>
        case .signInWithGoogle(let result):
            <#code#>
        case .signInWithApple(let result):
            <#code#>
        case .floater(let item):
            router.presentFloater(role: item.role, message: item.message)
        }
    }
}

// MARK: - View Conformation
extension AuthFeature: View {
    var body: some View {
        VStack {
            Header()
            
            Spacer()
            
            LoginButtonFeature()
            
            Spacer()
            Spacer()
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton(.xmark)
            }
        }
        .onChange(of: entity) {
            guard case .error(let item) = entity else { return }
            notify(.floater(item: item))
        }
    }
}

// MARK: - Subviews
extension AuthFeature {
    struct Header: View {
        var body: some View {
            VStack(spacing: 8) {
                Text("Log in")
                    .font(.title.weight(.medium))
                
                Text("Welcome back !")
            }
            .safeAreaPadding(.top, 98)
        }
    }
}

struct LoginButtonFeature {
    @Environment(\.router) private var router
    @Environment(\.memberRepository) private var memberRepository
    
    @FocusState private var isFocused: Bool
    
    var isPendingRegistration: Bool {
        memberRepository.authenticationState.isRegistrationNeeded
    }
}

// MARK: - ViewFeature Conformation
extension LoginButtonFeature: ViewFeature {
    enum UIEvent {
        
    }
    
    func notify(_ event: UIEvent) {
        
    }
}

// MARK: - View Conformation
extension LoginButtonFeature: View {
    var body: some View {
        VStack(spacing: 12) {
            if isPendingRegistration {
                
            } else {
                SignInWithGoogleButton(.continue) { result in
                    state.signInWithGoogle(result)
                }
                
                SignInWithAppleButton(.continue) { request in
                    request.nonce = UUID().uuidString
                    request.requestedScopes = [.email, .fullName]
                } onCompletion: { result in
                    state.signInWithApple(result)
                }
                .signInWithAppleButtonStyle(.whiteOutline)
                .frame(height: 44)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    AuthFeature()
}

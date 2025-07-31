//
//  LoginView.swift
//  RecipeForT
//
//  Created by Swain Yun on 6/22/25.
//

import SwiftUI
import AuthenticationServices
import GoogleSignInSwift

struct LoginView: View {
    @EnvironmentObject private var router: Router
    
    var body: some View {
        VStack {
            Header()
            
            Spacer()
            
            LoginButtonsArea()
            
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

// MARK: - Subviews
extension LoginView {
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
    
    struct LoginButtonsArea: View {
        @EnvironmentObject private var router: Router
        
        @State private var isRegistrationNeeded: Bool = true
        @FocusState private var isFocused: Bool
        
        var body: some View {
            VStack(spacing: 12) {
                if isRegistrationNeeded {
                    VStack(spacing: 12) {
                        Text("User name")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        RoundedTextField("Choose a username", text: .constant(""), $isFocused)
                        
                        Button {
                            
                        } label: {
                            Text("Continue")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        .buttonStyle(RoundedProminentButtonStyle(false, .white, .black, false))
                    }
                } else {
                    GoogleSignInButton(style: .wide) {
                        
                    }
                    .frame(height: 44)
                    
                    SignInWithAppleButton(.continue) { request in
                        
                    } onCompletion: { result in
                        
                    }
                    .signInWithAppleButtonStyle(.whiteOutline)
                    .frame(height: 44)
                }
                
                Button("딸깍") {
                    isRegistrationNeeded.toggle()
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    NavigationStack {
        LoginView()
    }
    .environmentObject(PreviewHelper.shared.router)
}

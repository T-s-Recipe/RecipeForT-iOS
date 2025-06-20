//
//  LoginView.swift
//  RecipeForT
//
//  Created by Swain Yun on 6/20/25.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject private var router: Router
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                Button {
                    router.dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
                .padding([.top, .trailing], )
                .tint(.black)
            }
            
            Spacer()
            
            SignInView()
            
            Spacer()
        }
    }
}

// MARK: - Subviews
struct LoginSection: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(.logo)
                .padding(.bottom, 12)
            
            Button {
                // TODO: SignInView로 연결
            } label: {
                Text("Log in")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                    .background(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            }
            .tint(.white)
            
            Button {
                // TODO: SignUpView로 연결
            } label: {
                Text("Sign up for free")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.white)
                            .strokeBorder(.gray)
                    )
            }
            .tint(.black)
        }
        .padding(.horizontal)
    }
}

struct SignInView: View {
    @State private var emailTextField: String = String()
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Welcome back")
                .font(.title.weight(.medium))
                .padding(.bottom, 12)
            
            SignInWithAppleButton(.continue) { request in
                
            } onCompletion: { result in
                
            }
            .signInWithAppleButtonStyle(.whiteOutline)
            .frame(height: 44)

            Text("OR")
            
            HStack {
                Text("Email address")
                    .foregroundStyle(.gray)
                
                Spacer()
            }
            
            RoundedTextField("(e.g) tsrecipe@gmail.com", text: $emailTextField)
            
            Button {
                
            } label: {
                Text("Continue")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                    .background(.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            }
            .tint(.white)
            
            HStack {
                Text("Don't have an account?")
                
                Button {
                    // TODO: SignUpView로 연결
                } label: {
                    Text("Sign up")
                }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    LoginView()
        .environmentObject(Router())
}

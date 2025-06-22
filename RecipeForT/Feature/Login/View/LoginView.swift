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
    @State private var sectionType: SectionType = .signUp
    
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
            
            Group {
                switch sectionType {
                case .login:
                    LoginSection(sectionType: $sectionType)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                case .signIn:
                    SignInSection(sectionType: $sectionType)
                        .transition(.scale.combined(with: .opacity))
                case .signUp:
                    SignUpSection(sectionType: $sectionType)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            
            Spacer()
        }
    }
}

// MARK: - Nested Types
extension LoginView {
    enum SectionType {
        case login
        case signIn
        case signUp
    }
}

// MARK: - Subviews
struct LoginSection: View {
    @Binding var sectionType: LoginView.SectionType
    
    var body: some View {
        VStack(spacing: 24) {
            Image(.logo)
                .padding(.bottom, 12)
            
            Button {
                withAnimation { sectionType = .signIn }
            } label: {
                Text("Log in")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                    .background(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            }
            .tint(.white)
            
            Button {
                withAnimation { sectionType = .signUp }
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

struct SignInSection: View {
    @Binding var sectionType: LoginView.SectionType
    @FocusState private var isEmailTextFieldFocused: Bool
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
            
            RoundedTextField("(e.g) tsrecipe@gmail.com", text: $emailTextField, $isEmailTextFieldFocused)
            
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
                    changeSectionToSignUp()
                } label: {
                    Text("Sign up")
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func changeSectionToSignUp() {
        isEmailTextFieldFocused = false
        withAnimation { sectionType = .signUp }
    }
}

struct SignUpSection: View {
    @Binding var sectionType: LoginView.SectionType
    @FocusState private var isFocused: Bool
    @State private var signUpStep: SignUpStep = .email
    @State private var textField: String = String()
    
    var body: some View {
        VStack {
            Header(signUpStep: $signUpStep)
            
            Spacer()
            
            VStack(spacing: 12) {
                if signUpStep == .email {
                    VStack(spacing: 12) {
                        SignInWithAppleButton(.continue) { request in
                            
                        } onCompletion: { result in
                            
                        }
                        .signInWithAppleButtonStyle(.whiteOutline)
                        .frame(height: 44)
                        
                        SignInWithAppleButton(.continue) { request in
                            
                        } onCompletion: { result in
                            
                        }
                        .signInWithAppleButtonStyle(.whiteOutline)
                        .frame(height: 44)
                        
                        Text("OR")
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                HStack {
                    Text(signUpStep == .email ? "Email address" : "User ID")
                        .foregroundStyle(.gray)
                    
                    Spacer()
                }
                
                RoundedTextField("(e.g) tsrecipe@gmail.com", text: $textField, $isFocused)
                
                Button {
                    withAnimation {
                        if signUpStep == .email {
                            signUpStep = .userID
                        } else {
                            signUpStep = .email
                        }
                    }
                } label: {
                    Text("Continue")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                        .background(.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }
                .tint(.white)
                
                HStack {
                    Text("Already have an account?")
                    
                    Button {
                        changeSectionToSignIn()
                    } label: {
                        Text("Log in")
                    }
                }
            }
            
            Spacer()
            
            Footer()
        }
        .padding(.horizontal)
    }
    
    private func changeSectionToSignIn() {
        isFocused = false
        withAnimation { sectionType = .signIn }
    }
}

// MARK: - SignUpSection + Nested Types
extension SignUpSection {
    enum SignUpStep {
        case email, userID
    }
}

// MARK: - SignUpSection + Subviews
extension SignUpSection {
    struct Header: View {
        @Binding var signUpStep: SignUpStep
        
        var body: some View {
            VStack(spacing: 12) {
                Image(.logo)
                
                Text("Create an account")
                    .font(.title.weight(.medium))
                
                HStack{
                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundStyle(signUpStep == .email ? .black : .gray)
                    
                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundStyle(signUpStep == .userID ? .black : .gray)
                }
                .padding(.top, 8)
            }
            .padding(.top)
        }
    }
    
    struct Footer: View {
        var body: some View {
            HStack {
                Link(destination: URL(string: "임시")!) {
                    Text("Terms of Use")
                        .underline()
                }
                
                Text("|")
                
                Link(destination: URL(string: "임시")!) {
                    Text("Privacy Policy")
                        .underline()
                }
            }
            .tint(.gray)
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(Router())
}

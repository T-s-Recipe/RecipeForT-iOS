//
//  LoginView.swift
//  RecipeForT
//
//  Created by Swain Yun on 6/22/25.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @State private var sectionType: SectionType
    
    init(sectionType: SectionType) {
        self.sectionType = sectionType
    }
    
    var body: some View {
        VStack {
            ScrollView(.vertical) {
                Header(sectionType: sectionType)
                
                ContentSection(sectionType: $sectionType)
            }
            .padding(.horizontal)
            
            if sectionType == .signUp {
                Footer()
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton()
            }
        }
    }
}

// MARK: - Nested Types
extension LoginView {
    enum SectionType {
        case signIn, signUp
    }
    
    enum SignUpStep {
        case email, userID
    }
}

// MARK: - Subviews
extension LoginView {
    struct Header: View {
        let sectionType: SectionType
        
        var body: some View {
            VStack(spacing: 8) {
                Text(sectionType == .signIn ? "Log in" : "Sign up for free")
                    .font(.title.weight(.medium))
                
                Text(sectionType == .signIn ? "Welcome back !" : "T's recipe")
            }
            .frame(height: 150)
        }
    }
    
    struct ContentSection: View {
        @Binding var sectionType: SectionType
        @FocusState private var isFocused: Bool
        @State private var signUpStep: SignUpStep = .email
        @State private var text = String()
        
        init(sectionType: Binding<SectionType>) {
            self._sectionType = sectionType
        }
        
        var body: some View {
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
                
                HStack {
                    Text(signUpStep == .email ? "Email address" : "User ID")
                        .foregroundStyle(.gray)
                    
                    Spacer()
                }
                
                RoundedTextField("(e.g) tsrecipe@gmail.com", text: $text, $isFocused)
                
                Button {
                    proceedSignUpStep()
                } label: {
                    Text("Continue")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                        .background(.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }
                .tint(.white)
                
                HStack {
                    Text(sectionType == .signIn ? "Don't have an account?" : "Already have an account?")
                    
                    Button {
                        toggleSectionType()
                    } label: {
                        Text(sectionType == .signIn ? "Sign up" : "Log in")
                    }
                }
            }
        }
        
        private func toggleSectionType() {
            sectionType = sectionType == .signIn ? .signUp : .signIn
        }
        
        private func proceedSignUpStep() {
            signUpStep = signUpStep == .email ? .userID : .email
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
    NavigationStack {
        LoginView(sectionType: .signIn)
    }
    .environmentObject(PreviewHelper.shared.router)
}

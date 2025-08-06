//
//  LoginView.swift
//  RecipeForT
//
//  Created by Swain Yun on 6/22/25.
//

import SwiftUI
import AuthenticationServices
import GoogleSignIn
import Swinject

struct LoginView: View {
    @EnvironmentObject private var router: Router
    
    @State private var viewModel: LoginViewModel
    
    init(resolver: Resolver) {
        self.viewModel = LoginViewModel(resolver: resolver)
    }
    
    var body: some View {
        VStack {
            Header()
            
            Spacer()
            
            LoginButtonsArea(viewModel)
            
            Spacer()
            Spacer()
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton(.xmark)
            }
        }
        .onChange(of: viewModel.floaterItem) { _, newValue in
            guard let newValue else { return }
            router.presentFloater(role: newValue.role, message: newValue.message)
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
        @FocusState private var isFocused: Bool
        @Bindable var viewModel: LoginViewModel
        
        init(_ viewModel: LoginViewModel) {
            self.viewModel = viewModel
        }
        
        var body: some View {
            VStack(spacing: 12) {
                if viewModel.isPendingRegistration {
                    VStack(spacing: 12) {
                        Text("User name")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        RoundedTextField(viewModel.temporalNickname, text: $viewModel.nicknameFieldText, $isFocused)
                        
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
                    SignInWithGoogleButton(.continue) { result in
                        viewModel.signInWithGoogle(result)
                    }
                    
                    SignInWithAppleButton(.continue) { request in
                        request.nonce = UUID().uuidString
                        request.requestedScopes = [.email, .fullName]
                    } onCompletion: { result in
                        viewModel.signInWithApple(result)
                    }
                    .signInWithAppleButtonStyle(.whiteOutline)
                    .frame(height: 44)
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    NavigationStack {
        LoginView(resolver: PreviewHelper.shared.resolver)
    }
    .environmentObject(PreviewHelper.shared.router)
}

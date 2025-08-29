//
//  SignInFeature.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/11/25.
//

import SwiftUI
import AuthenticationServices
import GoogleSignIn

@MainActor
struct SignInFeature {
    @Environment(\.router) private var router
    @Environment(MemberModel.self) private var memberModel
    @Binding var floaterItem: FloaterItem?
    @State private var state = SignInState()
}

// MARK: - ViewFeature Conformation
extension SignInFeature: ViewFeature {
    enum UIEvent {
        case signInWithGoogle(result: Result<GIDSignInResult, Error>)
        case signInWithApple(result: Result<ASAuthorization, Error>)
        case onFloaterItemChange(FloaterItem)
    }
    
    func notify(_ event: UIEvent) {
        switch event {
        case .signInWithGoogle(let result):
            signInWithGoogle(result)
        case .signInWithApple(let result):
            signInWithApple(result)
        case .onFloaterItemChange(let item):
            floaterItem = item
        }
    }
}

// MARK: - View Conformation
extension SignInFeature: View {
    var body: some View {
        VStack(spacing: 12) {
            SignInWithGoogleButton(.continue) { result in
                notify(.signInWithGoogle(result: result))
            }
            
            SignInWithAppleButton(.continue) { request in
                request.nonce = UUID().uuidString
                request.requestedScopes = [.email, .fullName]
            } onCompletion: { result in
                notify(.signInWithApple(result: result))
            }
            .signInWithAppleButtonStyle(.whiteOutline)
            .frame(height: 44)
        }
        .onChange(of: memberModel.isLoggedIn) { _, isLoggedIn in
            guard isLoggedIn else { return }
            router.dismiss()
        }
    }
}

// MARK: - Methods
private extension SignInFeature {
    func signInWithGoogle(_ result: Result<GIDSignInResult, Error>) {
        switch result {
        case .success(let auth):
            state.cancelTask(for: #function)
            
            let task = Task {
                state.isLoading = true
                defer { state.isLoading = false }
                
                guard let idToken = auth.user.idToken?.tokenString else { return }
                
                do {
                    try await memberModel.login(idToken: idToken, provider: .google)
                } catch {
                    let item = FloaterItem(role: .warning, message: FloaterMessageNamespace.authenticationNotCompleted.message)
                    notify(.onFloaterItemChange(item))
                }
            }
            
            state.storeTask(for: #function, task: task)
            
        case .failure:
            let item = FloaterItem(role: .warning, message: FloaterMessageNamespace.authenticationNotCompleted.message)
            notify(.onFloaterItemChange(item))
        }
    }
    
    func signInWithApple(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            state.cancelTask(for: #function)
            
            let task = Task {
                state.isLoading = true
                defer { state.isLoading = false }
                
                guard let credential = auth.credential as? ASAuthorizationAppleIDCredential,
                      let idTokenData = credential.identityToken,
                      let idToken = String(data: idTokenData, encoding: .utf8)
                else { return }
                
                do {
                    try await memberModel.login(idToken: idToken, provider: .apple)
                } catch {
                    let item = FloaterItem(role: .warning, message: FloaterMessageNamespace.authenticationNotCompleted.message)
                    notify(.onFloaterItemChange(item))
                }
            }
            
            state.storeTask(for: #function, task: task)
            
        case .failure:
            let item = FloaterItem(role: .warning, message: FloaterMessageNamespace.authenticationNotCompleted.message)
            notify(.onFloaterItemChange(item))
        }
    }
}

#Preview {
    AuthFeature()
}

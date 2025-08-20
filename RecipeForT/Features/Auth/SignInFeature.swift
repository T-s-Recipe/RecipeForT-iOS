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
    @Environment(\.memberRepository) private var memberRepository
    @State private var state = SignInState()
}

// MARK: - ViewFeature Conformation
extension SignInFeature: ViewFeature {
    enum UIEvent {
        case signInWithGoogle(result: Result<GIDSignInResult, Error>)
        case signInWithApple(result: Result<ASAuthorization, Error>)
    }
    
    func notify(_ event: UIEvent) {
        switch event {
        case .signInWithGoogle(let result):
            signInWithGoogle(result)
        case .signInWithApple(let result):
            signInWithApple(result)
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
        .onChange(of: state.entity) {
            guard case .error(let item) = state.entity else { return }
            router.presentFloater(role: item.role, message: item.message)
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
                state.entity = .loading
                
                guard let idToken = auth.user.idToken?.tokenString else { return state.entity = .initial }
                
                do {
                    let authState = try await memberRepository.signIn(idToken: idToken, provider: .google)
                    state.entity = .loaded(authState)
                    
                    if case .loggedIn = authState { router.dismiss() }
                } catch {
                    let item = FloaterItem(role: .warning, message: FloaterMessageNamespace.authenticationNotCompleted)
                    state.entity = .error(item)
                }
            }
            
            state.storeTask(for: #function, task: task)
            
        case .failure:
            let item = FloaterItem(role: .warning, message: FloaterMessageNamespace.authenticationNotCompleted)
            state.entity = .error(item)
        }
    }
    
    func signInWithApple(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            state.cancelTask(for: #function)
            
            let task = Task {
                state.entity = .loading
                
                guard let credential = auth.credential as? ASAuthorizationAppleIDCredential,
                      let idTokenData = credential.identityToken,
                      let idToken = String(data: idTokenData, encoding: .utf8)
                else { return state.entity = .initial }
                
                do {
                    let authState = try await memberRepository.signIn(idToken: idToken, provider: .apple)
                    state.entity = .loaded(authState)
                    
                    if case .loggedIn = authState { router.dismiss() }
                } catch {
                    let item = FloaterItem(role: .warning, message: FloaterMessageNamespace.authenticationNotCompleted)
                    state.entity = .error(item)
                }
            }
            
            state.storeTask(for: #function, task: task)
            
        case .failure:
            let item = FloaterItem(role: .warning, message: FloaterMessageNamespace.authenticationNotCompleted)
            state.entity = .error(item)
        }
    }
}

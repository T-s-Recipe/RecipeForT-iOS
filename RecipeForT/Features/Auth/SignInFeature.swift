//
//  SignInFeature.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/11/25.
//

import SwiftUI
import AuthenticationServices
import GoogleSignIn
import ComposableArchitecture

@Reducer
struct SignInFeature {
    @ObservableState
    struct State: Equatable {
        
    }
    
    enum Action {
        @CasePathable
        enum Delegate {
            case loginCompleted(AuthClient.SignInOutcome)
            case loginFailed(FloaterItem)
        }
        
        case signInWithGoogle(result: Result<GIDSignInResult, Error>)
        case signInWithApple(result: Result<ASAuthorization, Error>)
        case signInResponse(result: Result<AuthClient.SignInOutcome, Error>)
        case delegate(Delegate)
    }
    
    @Dependency(\.authClient) var authClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .signInWithGoogle(let result):
                switch result {
                case .success(let auth):
                    guard let idToken = auth.user.idToken?.tokenString else {
                        let item = FloaterItem(role: .warning, message: FloaterMessageNamespace.authenticationNotCompleted.message)
                        return .send(.delegate(.loginFailed(item)))
                    }
                    
                    return .run { send in
                        do {
                            let signInOutcome = try await authClient.login(idToken, .google)
                            await send(.signInResponse(result: .success(signInOutcome)))
                        } catch {
                            await send(.signInResponse(result: .failure(error)))
                        }
                    }
                    
                case .failure:
                    let item = FloaterItem(role: .warning, message: FloaterMessageNamespace.authenticationNotCompleted.message)
                    return .send(.delegate(.loginFailed(item)))
                }
                
            case .signInWithApple(let result):
                switch result {
                case .success(let auth):
                    guard let credential = auth.credential as? ASAuthorizationAppleIDCredential,
                          let idTokenData = credential.identityToken,
                          let idToken = String(data: idTokenData, encoding: .utf8)
                    else {
                        let item = FloaterItem(role: .warning, message: FloaterMessageNamespace.authenticationNotCompleted.message)
                        return .send(.delegate(.loginFailed(item)))
                    }
                    
                    return .run { send in
                        do {
                            let signInOutcome = try await authClient.login(idToken, .apple)
                            await send(.signInResponse(result: .success(signInOutcome)))
                        } catch {
                            await send(.signInResponse(result: .failure(error)))
                        }
                    }
                    
                case .failure:
                    let item = FloaterItem(role: .warning, message: FloaterMessageNamespace.authenticationNotCompleted.message)
                    return .send(.delegate(.loginFailed(item)))
                }
                
            case .signInResponse(let result):
                switch result {
                case .success(let outcome):
                    return .send(.delegate(.loginCompleted(outcome)))
                case .failure:
                    let item = FloaterItem(role: .warning, message: FloaterMessageNamespace.authenticationNotCompleted.message)
                    return .send(.delegate(.loginFailed(item)))
                }
                
            case .delegate:
                return .none
            }
        }
    }
}

struct SignInView: View {
    let store: StoreOf<SignInFeature>
    
    var body: some View {
        VStack(spacing: 12) {
            SignInWithGoogleButton(.continue) { result in
                store.send(.signInWithGoogle(result: result))
            }
            
            SignInWithAppleButton(.continue) { request in
                request.nonce = UUID().uuidString
                request.requestedScopes = [.email, .fullName]
            } onCompletion: { result in
                store.send(.signInWithApple(result: result))
            }
            .signInWithAppleButtonStyle(.whiteOutline)
            .frame(height: 44)
        }
    }
}

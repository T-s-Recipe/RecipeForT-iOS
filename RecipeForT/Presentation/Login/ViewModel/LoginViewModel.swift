//
//  LoginViewModel.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/4/25.
//

import Foundation
import Swinject
import AuthenticationServices
import GoogleSignIn

@Observable @MainActor
final class LoginViewModel {
    private var authenticationState: AuthenticationState
    private var currentAttemptRecord: SignInAttemptRecord?
    var isPendingRegistration: Bool { authenticationState.isRegistrationNeeded }
    var floaterItem: FloaterItem?
    var temporalNickname: String = String()
    var nicknameFieldText: String = String()
    
    private var tasks = [String: Task<Void, Never>]()
    
    private let memberRepository: MemberRepositoryProtocol
    
    init(resolver: Resolver) {
        let memberRepository = resolver.resolve(MemberRepositoryProtocol.self)!
        authenticationState = memberRepository.authenticationState
        self.memberRepository = memberRepository
    }
    
    private func prepareSignUpSquence(_ state: AuthenticationState) async {
        guard case .pendingRegistration = state else { return }
        
        do {
            let temporalNickname = try await memberRepository.fetchRandomNickname()
            self.temporalNickname = temporalNickname
            nicknameFieldText = temporalNickname
        } catch {
            temporalNickname.removeAll()
            nicknameFieldText.removeAll()
        }
    }
}

// MARK: - Interfaces
extension LoginViewModel {
    func signInWithGoogle(_ result: Result<GIDSignInResult, any Error>) {
        switch result {
        case .success(let auth):
            tasks[#function]?.cancel()
            
            guard let idToken = auth.user.idToken?.tokenString,
                  let authCode = Data(base64Encoded: idToken)
            else { return }
            let name = auth.user.profile?.name
            let email = auth.user.profile?.email
            
            let task = Task {
                do {
                    self.currentAttemptRecord = .init(authCode: authCode, provider: .google, name: name, email: email)
                    let authenticationState = try await memberRepository.signIn(authCode: authCode, provider: .google, name: name, email: email)
                    await prepareSignUpSquence(authenticationState)
                    self.authenticationState = authenticationState
                } catch {
                    floaterItem = .init(role: .warning, message: FloaterMessageNamespace.authenticationNotCompleted)
                }
            }
            
            tasks[#function] = task
            
        case .failure:
            floaterItem = .init(role: .warning, message: FloaterMessageNamespace.authenticationNotCompleted)
        }
    }
    
    func signInWithApple(_ result: Result<ASAuthorization, any Error>) {
        switch result {
        case .success(let auth):
            tasks[#function]?.cancel()
            
            guard let credential = auth.credential as? ASAuthorizationAppleIDCredential,
                  let authCode = credential.authorizationCode
            else { return }
            
            let name = credential.fullName?.nickname
            let email = credential.email
            
            let task = Task {
                do {
                    self.currentAttemptRecord = .init(authCode: authCode, provider: .apple, name: name, email: email)
                    let authenticationState = try await memberRepository.signIn(authCode: authCode, provider: .apple, name: name, email: email)
                    await prepareSignUpSquence(authenticationState)
                    self.authenticationState = authenticationState
                } catch {
                    floaterItem = .init(role: .warning, message: FloaterMessageNamespace.authenticationNotCompleted)
                }
            }
            
            tasks[#function] = task
            
        case .failure:
            floaterItem = .init(role: .warning, message: FloaterMessageNamespace.authenticationNotCompleted)
        }
    }
    
    func signUp() {
        tasks[#function]?.cancel()
        
        guard temporalNickname.isEmpty == false else {
            return floaterItem = .init(role: .warning, message: FloaterMessageNamespace.unknownErrorOccurred)
        }
        
        guard let currentAttemptRecord else {
            return floaterItem = .init(role: .warning, message: FloaterMessageNamespace.unknownErrorOccurred)
        }
        
        let task = Task {
            let nickname = nicknameFieldText.isEmpty ? temporalNickname : nicknameFieldText
            
            do {
                let authenticationState = try await memberRepository.signUp(
                    authCode: currentAttemptRecord.authCode,
                    provider: currentAttemptRecord.provider,
                    name: currentAttemptRecord.name,
                    email: currentAttemptRecord.email,
                    nickname: nickname
                )
                self.authenticationState = authenticationState
                floaterItem = .init(message: FloaterMessageNamespace.accountCreated)
            } catch {
                floaterItem = .init(role: .warning, message: FloaterMessageNamespace.authenticationNotCompleted)
            }
        }
        
        tasks[#function] = task
    }
}

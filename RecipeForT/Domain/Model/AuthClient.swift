//
//  AuthClient.swift
//  RecipeForT
//
//  Created by Swain Yun on 9/2/25.
//

import Foundation
import ComposableArchitecture

final actor LiveAuthModel {
    struct Constants {
        static let maximumNicknameLength: Int = 15
    }
    
    private var authenticationState: AuthenticationState = .loggedOut
    
    let stream: AsyncStream<AuthenticationState>
    private var continuation: AsyncStream<AuthenticationState>.Continuation
    private let memberRepository: MemberRepositoryProtocol
    
    init(memberRepository: MemberRepositoryProtocol) {
        self.memberRepository = memberRepository
        
        var streamContinuation: AsyncStream<AuthenticationState>.Continuation?
        self.stream = AsyncStream { streamContinuation = $0 }
        self.continuation = streamContinuation!
        Task { await attemptAutoLogin() }
    }
    
    private func updateAuthState(_ state: AuthenticationState) {
        authenticationState = state
        continuation.yield(state)
    }
    
    private func attemptAutoLogin() async {
        do {
            let member = try await memberRepository.fetchMember()
            updateAuthState(.loggedIn(member: member))
        } catch {
            updateAuthState(.loggedOut)
            await memberRepository.logout()
        }
    }
    
    func login(idToken: String, provider: OAuthProvider) async throws -> AuthClient.SignInOutcome {
        do {
            let record = try await memberRepository.signIn(idToken: idToken, provider: provider)
            
            if record.isRegistrationNeeded {
                updateAuthState(.pendingRegistration(record: record))
                return .registrationNeeded(record)
            } else {
                let member = try await memberRepository.fetchMember()
                updateAuthState(.loggedIn(member: member))
                return .loggedIn(member)
            }
        } catch {
            updateAuthState(.loggedOut)
            throw error
        }
    }
    
    func logout() async {
        await memberRepository.logout()
        updateAuthState(.loggedOut)
    }
    
    func register(record: SignInAttemptRecord, nickname: String) async throws -> Member {
        do {
            let member = try await memberRepository.signUp(ci: record.ci, provider: record.provider, nickname: nickname)
            updateAuthState(.loggedIn(member: member))
            return member
        } catch {
            updateAuthState(.loggedOut)
            throw error
        }
    }
    
    func unregister() async throws {
        guard case .loggedIn = authenticationState else { return }
        try await memberRepository.deleteMember()
        updateAuthState(.loggedOut)
    }
    
    func fetchRandomNickname() async throws -> String {
        try await memberRepository.fetchRandomNickname()
    }
    
    func validateNickname(_ nickname: String) async throws -> NicknameValidationState {
        guard nickname.isEmpty == false else { return .emptyNickname }
        guard nickname.count <= Constants.maximumNicknameLength else { return .limitExceeded }
        
        let isDuplicated = try await memberRepository.isNicknameDuplicated(nickname: nickname)
        return isDuplicated ? .duplicated : .valid
    }
}

struct AuthClient: Sendable {
    /// 로그인 결과
    enum SignInOutcome {
        case loggedIn(Member)
        case registrationNeeded(SignInAttemptRecord)
    }
    
    var authenticationState: @Sendable () -> AsyncStream<AuthenticationState>
    var login: @Sendable (_ idToken: String, _ provider: OAuthProvider) async throws -> SignInOutcome
    var logout: @Sendable () async -> Void
    var register: @Sendable (_ record: SignInAttemptRecord, _ nickname: String) async throws -> Member
    var unregister: @Sendable () async throws -> Void
    var fetchRandomNickname: @Sendable () async throws -> String
    var validateNickname: @Sendable (_ nickname: String) async throws -> NicknameValidationState
}

//
//  MemberModel.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/25/25.
//

import Foundation

@Observable
final class MemberModel {
    private struct Constants {
        static let maximumNicknameLength: Int = 15
    }
    
    private var authenticationState: AuthenticationState = .loggedOut
    var user: Member? {
        guard case .loggedIn(let member) = authenticationState else { return nil }
        return member
    }
    var isLoggedIn: Bool { user != nil }
    var isPendingRegistration: Bool { authenticationState.isRegistrationNeeded }
    
    private let memberRepository: MemberRepositoryProtocol
    
    init(memberRepository: MemberRepositoryProtocol) {
        self.memberRepository = memberRepository
    }
}

// MARK: - Interfaces
extension MemberModel {
    func attemptAutoLogin() {
        Task {
            guard let member = try? await memberRepository.fetchMember() else { return }
            authenticationState = .loggedIn(member: member)
        }
    }
    
    func login(idToken: String, provider: OAuthProvider) async throws {
        do {
            let record = try await memberRepository.signIn(idToken: idToken, provider: provider)
            
            guard record.isRegistrationNeeded == false else { return authenticationState = .pendingRegistration(record: record) }
            
            let member = try await memberRepository.fetchMember()
            authenticationState = .loggedIn(member: member)
        } catch {
            authenticationState = .loggedOut
            throw error
        }
    }
    
    func logout() async throws {
        await memberRepository.logout()
        authenticationState = .loggedOut
    }
    
    func register(nickname: String) async throws {
        guard case .pendingRegistration(let record) = authenticationState else { return }
        
        do {
            let member = try await memberRepository.signUp(ci: record.ci, provider: record.provider, nickname: nickname)
            authenticationState = .loggedIn(member: member)
        } catch {
            authenticationState = .loggedOut
            throw error
        }
    }
    
    func fetchRandomNickname() async throws -> String {
        try await memberRepository.fetchRandomNickname()
    }
    
    func validateNickname(_ nickname: String) async -> NicknameValidationState {
        guard nickname.isEmpty == false else { return .emptyNickname }
        guard nickname.count <= Constants.maximumNicknameLength else { return .limitExceeded }
        
        do {
            guard try await memberRepository.isNicknameDuplicated(nickname: nickname) else { return .duplicated }
            return .valid
        } catch {
            return .emptyNickname
        }
    }
}

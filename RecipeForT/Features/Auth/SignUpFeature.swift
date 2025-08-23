//
//  SignUpFeature.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/11/25.
//

import SwiftUI

@MainActor
struct SignUpFeature {
    struct Constants {
        static let title = "User name"
        static let buttonLabel = "Continue"
        static let nicknameTextFieldPlaceholder = "Type your nickname"
    }
    
    @Environment(\.router) private var router
    @Environment(\.memberRepository) private var memberRepository
    @Binding var isPendingRegistration: Bool
    @Binding var floaterItem: FloaterItem?
    @FocusState private var isFocused: Bool
    @State private var state = SignUpState()
    
    private var isLoading: Bool { state.entity == .loading }
}

// MARK: - ViewFeature Conformation
extension SignUpFeature: ViewFeature {
    enum UIEvent {
        case task
        case continueTapped
        case onFloaterItemChange(FloaterItem)
    }
    
    func notify(_ event: UIEvent) {
        switch event {
        case .task:
            fetchTemporalNickname()
        case .continueTapped:
            signUp()
        case .onFloaterItemChange(let item):
            floaterItem = item
        }
    }
}

// MARK: - View Conformation
extension SignUpFeature: View {
    var body: some View {
        VStack(spacing: 12) {
            Text(Constants.title)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            RoundedTextField(Constants.nicknameTextFieldPlaceholder, text: $state.nicknameFieldText, $isFocused)
            
            Button {
                notify(.continueTapped)
            } label: {
                Text(Constants.buttonLabel)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.roundedProminent(disabled: state.nicknameFieldText.isEmpty, foreground: .white, background: .black, isLoading: isLoading))
            .submitLabel(.continue)
            .onSubmit { notify(.continueTapped) }
        }
        .task {
            notify(.task)
        }
        .onChange(of: state.entity) {
            if case .loaded(let authState) = state.entity, authState.isRegistrationNeeded == false {
                router.dismiss()
            }
            
            guard case .error(let item) = state.entity else { return }
            notify(.onFloaterItemChange(item))
        }
    }
}

// MARK: - Methods
private extension SignUpFeature {
    func fetchTemporalNickname() {
        state.cancelTask(for: #function)
        
        let task = Task {
            state.entity = .loading
            
            defer { state.entity = .initial }
            
            do {
                let temporalNickname = try await memberRepository.fetchRandomNickname()
                guard Task.isCancelled == false else { return }
                state.updateTemporalNickname(temporalNickname)
            } catch {
                let floaterItem = FloaterItem(role: .warning, message: FloaterMessageNamespace.unknownErrorOccurred)
                state.entity = .error(floaterItem)
            }
        }
        
        state.storeTask(for: #function, task: task)
    }
    
    func signUp() {
        state.cancelTask(for: #function)
        
        guard state.nicknameFieldText.isEmpty == false else {
            let floraterItem = FloaterItem(role: .warning, message: FloaterMessageNamespace.unknownErrorOccurred)
            return state.entity = .error(floraterItem)
        }
        
        let submittedNickname: String = state.nicknameFieldText
        
        let task = Task {
            state.entity = .loading
            
            do {
                let authenticationState = try await memberRepository.signUp(nickname: submittedNickname)
                state.entity = .loaded(authenticationState)
            } catch {
                let floaterItem = FloaterItem(role: .warning, message: FloaterMessageNamespace.authenticationNotCompleted)
                state.entity = .error(floaterItem)
            }
        }
        
        state.storeTask(for: #function, task: task)
    }
}

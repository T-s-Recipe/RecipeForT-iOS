//
//  SignUpFeature.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/11/25.
//

import SwiftUI

@MainActor
struct SignUpFeature {
    enum Constants: String, CustomStringConvertible {
        case title = "User name"
        case buttonLabel = "Continue"
        
        var description: String { self.rawValue }
    }
    
    @Environment(\.router) private var router
    @Environment(\.memberRepository) private var memberRepository
    @FocusState private var isFocused: Bool
    @State private var state = SignUpState()
    
    private var isLoading: Bool { state.entity == .loading }
}

// MARK: - ViewFeature Conformation
extension SignUpFeature: ViewFeature {
    enum UIEvent {
        case task
        case continueTapped
    }
    
    func notify(_ event: UIEvent) {
        switch event {
        case .task:
            fetchTemporalNickname()
        case .continueTapped:
            signUp()
        }
    }
}

// MARK: - View Conformation
extension SignUpFeature: View {
    var body: some View {
        VStack(spacing: 12) {
            Text(Constants.title.description)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            RoundedTextField(state.temporalNickname, text: $state.nicknameFieldText, $isFocused)
            
            Button {
                notify(.continueTapped)
            } label: {
                Text(Constants.buttonLabel.description)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.roundedProminent(foreground: .white, background: .black, isLoading: isLoading))
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
            router.presentFloater(role: item.role, message: item.message)
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
        
        guard state.temporalNickname.isEmpty == false else {
            let floraterItem = FloaterItem(role: .warning, message: FloaterMessageNamespace.unknownErrorOccurred)
            return state.entity = .error(floraterItem)
        }
        
        let task = Task {
            state.entity = .loading
            
            do {
                let authenticationState = try await memberRepository.signUp(nickname: state.nicknameFieldText)
                state.entity = .loaded(authenticationState)
            } catch {
                let floaterItem = FloaterItem(role: .warning, message: FloaterMessageNamespace.authenticationNotCompleted)
                state.entity = .error(floaterItem)
            }
        }
        
        state.storeTask(for: #function, task: task)
    }
}

#Preview {
    SignUpFeature()
}

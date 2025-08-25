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
    @Environment(MemberModel.self) private var memberModel
    @Binding var floaterItem: FloaterItem?
    @FocusState private var isFocused: Bool
    @State private var state = SignUpState()
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
            .buttonStyle(.roundedProminent(disabled: state.nicknameFieldText.isEmpty, foreground: .white, background: .black, isLoading: state.isLoading))
            .submitLabel(.continue)
            .onSubmit { notify(.continueTapped) }
        }
        .task {
            notify(.task)
        }
        .onChange(of: memberModel.isLoggedIn) { _, isLoggedIn in
            guard isLoggedIn else { return }
            router.dismiss()
        }
    }
}

// MARK: - Methods
private extension SignUpFeature {
    func fetchTemporalNickname() {
        state.cancelTask(for: #function)
        
        let task = Task {
            state.isLoading = true
            defer { state.isLoading = false }
            
            do {
                let temporalNickname = try await memberModel.fetchRandomNickname()
                guard Task.isCancelled == false else { return }
                state.updateTemporalNickname(temporalNickname)
            } catch {
                let floaterItem = FloaterItem(role: .warning, message: FloaterMessageNamespace.unknownErrorOccurred)
                notify(.onFloaterItemChange(floaterItem))
            }
        }
        
        state.storeTask(for: #function, task: task)
    }
    
    func signUp() {
        state.cancelTask(for: #function)
        
        guard state.nicknameFieldText.isEmpty == false else {
            let floaterItem = FloaterItem(role: .warning, message: FloaterMessageNamespace.unknownErrorOccurred)
            return notify(.onFloaterItemChange(floaterItem))
        }
        
        let submittedNickname: String = state.nicknameFieldText
        
        let task = Task {
            state.isLoading = true
            defer { state.isLoading = false }
            
            do {
                try await memberModel.register(nickname: submittedNickname)
            } catch {
                let floaterItem = FloaterItem(role: .warning, message: FloaterMessageNamespace.authenticationNotCompleted)
                notify(.onFloaterItemChange(floaterItem))
            }
        }
        
        state.storeTask(for: #function, task: task)
    }
}

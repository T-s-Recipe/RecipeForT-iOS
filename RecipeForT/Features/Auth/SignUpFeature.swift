//
//  SignUpFeature.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/11/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct SignUpFeature {
    struct Constants {
        static let nicknameDuplicatedErrorMessage: String = "This nickname is already in use."
        static let nicknameLimitExceededErrorMessage: String = "Character limit exceeded."
        static let emptyNicknameErrorMessage: String = "This field is required."
    }
    
    @CasePathable
    enum CancelID {
        case fetchRandomNickname
        case nicknameChanged
        case validateNickname
    }
    
    @ObservableState
    struct State: Equatable {
        let title = "User name"
        let buttonLabel = "Continue"
        let nicknameTextFieldPlaceholder = "Type your nickname"
        let record: SignInAttemptRecord
        
        var nickname: String = String()
        var validationState: NicknameValidationState = .valid
        var nicknameValidationMessage: String?
        var isContinueButtonDisabled: Bool = true
        var isLoading: Bool = false
    }
    
    enum Action {
        @CasePathable
        enum ViewAction {
            case fetchRandomNickname
            case nicknameChanged(String)
            case continueButtonTapped
        }
        
        @CasePathable
        enum InternalAction {
            case fetchRandomNicknameResponse(Result<String, Error>)
            case validateNicknameResponse(NicknameValidationState)
        }
        
        @CasePathable
        enum Delegate {
            case randomNicknameFetchingFailed(FloaterItem)
            case nicknameValidationFailed(FloaterItem)
            case registrationSuccessed(Member)
            case registrationFailed(FloaterItem)
        }
        
        case view(ViewAction)
        case `internal`(InternalAction)
        case delegate(Delegate)
    }
    
    @Dependency(\.authClient) var authClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(.fetchRandomNickname):
                state.isLoading = true
                return .run { send in
                    do {
                        let temporalNickname = try await authClient.fetchRandomNickname()
                        await send(.internal(.fetchRandomNicknameResponse(.success(temporalNickname))))
                    } catch {
                        await send(.internal(.fetchRandomNicknameResponse(.failure(error))))
                    }
                }
                .cancellable(id: CancelID.fetchRandomNickname)
                
            case .view(.nicknameChanged(let nickname)):
                state.nickname = nickname
                state.isContinueButtonDisabled = true
                state.nicknameValidationMessage = nil
                state.isLoading = true
                return .run { send in
                    do {
                        let validationState = try await authClient.validateNickname(nickname)
                        await send(.internal(.validateNicknameResponse(validationState)))
                    } catch {
                        let item = FloaterItem(role: .warning, message: FloaterMessageNamespace.unknownErrorOccurred.message)
                        await send(.delegate(.nicknameValidationFailed(item)))
                    }
                }
                .debounce(id: CancelID.nicknameChanged, for: .seconds(0.8), scheduler: DispatchQueue.main)
                
            case .view(.continueButtonTapped):
                guard state.isContinueButtonDisabled == false else { return .none }
                state.isContinueButtonDisabled = true
                state.isLoading = true
                return .run { [record = state.record, nickname = state.nickname] send in
                    do {
                        let member = try await authClient.register(record, nickname)
                        await send(.delegate(.registrationSuccessed(member)))
                    } catch {
                        let item = FloaterItem(role: .warning, message: FloaterMessageNamespace.unknownErrorOccurred.message)
                        await send(.delegate(.registrationFailed(item)))
                    }
                }
                
            case .internal(.fetchRandomNicknameResponse(.success(let temporalNickname))):
                state.isLoading = false
                return .send(.view(.nicknameChanged(temporalNickname)))
                
            case .internal(.fetchRandomNicknameResponse(.failure)):
                state.isLoading = false
                let item = FloaterItem(role: .warning, message: FloaterMessageNamespace.unknownErrorOccurred.message)
                return .send(.delegate(.randomNicknameFetchingFailed(item)))
                
            case .internal(.validateNicknameResponse(let validationState)):
                state.isLoading = false
                state.validationState = validationState
                state.isContinueButtonDisabled = validationState != .valid
                
                switch validationState {
                case .valid:
                    state.nicknameValidationMessage = nil
                case .duplicated:
                    state.nicknameValidationMessage = Constants.nicknameDuplicatedErrorMessage
                case .limitExceeded:
                    state.nicknameValidationMessage = Constants.nicknameLimitExceededErrorMessage
                case .emptyNickname:
                    state.nicknameValidationMessage = Constants.emptyNicknameErrorMessage
                }
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
}

struct SignUpView: View {
    @Bindable var store: StoreOf<SignUpFeature>
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Text(store.title)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            RoundedTextField(
                store.nicknameTextFieldPlaceholder,
                text: $store.nickname.sending(\.view.nicknameChanged),
                $isFocused,
                state: store.validationState.isError ? .onError : .normal
            )
            
            if let message = store.nicknameValidationMessage {
                Text(message)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(.hex(0xE51220))
            }
            
            Button {
                store.send(.view(.continueButtonTapped))
            } label: {
                Text(store.buttonLabel)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.roundedProminent(disabled: store.isContinueButtonDisabled, foreground: .white, background: .black, isLoading: store.isLoading))
            .submitLabel(.continue)
            .onSubmit { store.send(.view(.continueButtonTapped)) }
            .disabled(store.isContinueButtonDisabled)
        }
        .task {
            store.send(.view(.fetchRandomNickname))
        }
    }
}

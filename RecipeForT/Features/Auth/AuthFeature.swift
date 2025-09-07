//
//  AuthFeature.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/11/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct AuthFeature {
    @Reducer(state: .equatable)
    enum Screen {
        case signIn(SignInFeature)
        case signUp(SignUpFeature)
    }
    
    @ObservableState
    struct State: Equatable {
        var screen: Screen.State = .signIn(.init())
        var floaterItem: FloaterItem?
    }
    
    enum Action {
        case presentFloaterItem(FloaterItem?)
        case dismiss
        case screen(Screen.Action)
    }
    
    @Dependency(\.dismiss) var dismiss
    
    var body: some Reducer<State, Action> {
        Scope(state: \.screen, action: \.screen) {
            Screen.body
        }
        
        Reduce { state, action in
            switch action {
            case .dismiss:
                return .run { _ in await dismiss() }
                
            case .presentFloaterItem(let item):
                state.floaterItem = item
                return .none
                
            case .screen(.signIn(.delegate(let delegateAction))):
                switch delegateAction {
                case .loginCompleted(let outcome):
                    switch outcome {
                    case .loggedIn:
                        return .run { _ in await dismiss() }
                        
                    case .registrationNeeded(let record):
                        if record.isRegistrationNeeded {
                            return .run { _ in await dismiss() }
                        } else {
                            state.screen = .signUp(SignUpFeature.State(record: record))
                            return .none
                        }
                    }
                    
                case .loginFailed(let item):
                    state.floaterItem = item
                    return .none
                }
                
            case .screen(.signUp(.delegate(let delegateAction))):
                switch delegateAction {
                case .registrationSuccessed:
                    return .run { _ in await dismiss() }
                    
                case .nicknameValidationFailed(let item):
                    return .send(.presentFloaterItem(item))
                    
                case .randomNicknameFetchingFailed(let item):
                    return .send(.presentFloaterItem(item))
                    
                case .registrationFailed(let item):
                    return .send(.presentFloaterItem(item))
                }
                
            case .screen:
                return .none
            }
        }
    }
}

struct AuthView: View {
    enum Constants: String, CustomStringConvertible {
        case title = "Log in"
        case subtitle = "Welcome back !"
        
        var description: String { self.rawValue }
    }
    
    @Bindable var store: StoreOf<AuthFeature>
    
    var body: some View {
        VStack {
            HStack {
                BackButton(.xmark)
                
                Spacer()
            }
            .padding(.horizontal)
            
            VStack(spacing: 8) {
                Text(Constants.title.description)
                    .font(.title.weight(.medium))
                
                Text(Constants.subtitle.description)
            }
            .safeAreaPadding(.top, 98)
            
            Spacer()
            
            VStack(spacing: 12) {
                SwitchStore(store.scope(state: \.screen, action: \.screen)) { initialState in
                    switch initialState {
                    case .signIn:
                        if let signInStore = store.scope(state: \.screen.signIn, action: \.screen.signIn) {
                            SignInView(store: signInStore)
                        }
                    case .signUp:
                        if let signUpStore = store.scope(state: \.screen.signUp, action: \.screen.signUp) {
                            SignUpView(store: signUpStore)
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
            Spacer()
        }
        .floater($store.floaterItem.sending(\.presentFloaterItem))
    }
}

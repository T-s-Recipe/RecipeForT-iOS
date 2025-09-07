//
//  PreferenceFeature.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/12/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct PreferenceFeature {
    @ObservableState
    struct State: Equatable {
        var authState: AuthenticationState
        var notices: AnnouncementContentPreviewListFeature.State
        var inquiries: AnnouncementContentPreviewListFeature.State
        @Presents var destination: Destination.State?
        
        init(authState: AuthenticationState) {
            self.authState = authState
            notices = .init(type: .notice, contents: [])
            inquiries = .init(type: .QNA, contents: [])
        }
    }
    
    enum Action {
        @CasePathable
        enum ViewAction {
            case task
            case deleteAccountButtonTapped
        }
        
        @CasePathable
        enum InternalAction {
            case announcementsResponse(Result<[AnnouncementItem], Error>)
            case deleteAccountResponse(Result<Void, Error>)
        }
        
        @CasePathable
        enum Delegate {
            case presentNotices
            case presentInquiries
        }
        
        case view(ViewAction)
        case `internal`(InternalAction)
        case delegate(Delegate)
        
        case notices(AnnouncementContentPreviewListFeature.Action)
        case inquiries(AnnouncementContentPreviewListFeature.Action)
        case destination(PresentationAction<Destination.Action>)
    }
    
    @Reducer
    struct Destination {
        @ObservableState
        enum State: Equatable {
            case confirmDeletion(AlertState<Action.ConfirmDeletion>)
        }
        
        enum Action {
            @CasePathable
            enum ConfirmDeletion {
                case confirmButtonTapped
                case cancel
            }
            
            case confirmDeletion(ConfirmDeletion)
        }
        
        var body: some Reducer<State, Action> {
            Reduce { _, _ in .none }
        }
    }
    
    @Dependency(\.authClient) var authClient
    
    var body: some Reducer<State, Action> {
        Scope(state: \.notices, action: \.notices) { AnnouncementContentPreviewListFeature() }
        Scope(state: \.inquiries, action: \.inquiries) { AnnouncementContentPreviewListFeature() }
        
        Reduce { state, action in
            switch action {
            case .view(.task):
                // TODO: Data Fetching
                return .none
                
            case .view(.deleteAccountButtonTapped):
                state.destination = .confirmDeletion(.deleteAccount)
                return .none
                
            case .notices(.delegate(.seeMoreTapped)):
                return .send(.delegate(.presentNotices))
                
            case .inquiries(.delegate(.seeMoreTapped)):
                return .send(.delegate(.presentInquiries))
                
            case .destination(.presented(.confirmDeletion(.confirmButtonTapped))):
                return .run { send in
                    do {
                        try await authClient.unregister()
                        await send(.internal(.deleteAccountResponse(.success(()))))
                    } catch {
                        await send(.internal(.deleteAccountResponse(.failure(error))))
                    }
                }
                
            case .internal(.deleteAccountResponse(.success)):
                return .none
                
            case .internal(.deleteAccountResponse(.failure)):
                // TODO: Floater 표시
                return .none
                
            case .notices, .inquiries, .destination, .delegate, .internal:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination) { Destination() }
    }
}

extension AlertState where Action == PreferenceFeature.Destination.Action.ConfirmDeletion {
    static let deleteAccount = Self {
        TextState("Delete Account")
    } actions: {
        ButtonState(role: .destructive, action: .confirmButtonTapped) {
            TextState("Confirm")
        }
        
        ButtonState(role: .cancel, action: .cancel) {
            TextState("Cancel")
        }
    } message: {
        TextState("Are you sure you want to delete your account? This action cannot be undone.")
    }
}

struct PreferenceView: View {
    let store: StoreOf<PreferenceFeature>
    
    var body: some View {
        ScrollView(.vertical) {
            accountSection()
            
            thickDivider
            
            AnnouncementContentPreviewListView(store: store.scope(state: \.notices, action: \.notices))
            
            thickDivider
            
            AnnouncementContentPreviewListView(store: store.scope(state: \.inquiries, action: \.inquiries))
            
            thickDivider
            
            VStack {
                HStack(spacing: 16) {
                    Text("App version")
                    Text("0.0.1")
                }
                .padding()
                
                Divider()
                    .padding(.horizontal)
                
                HStack(spacing: 12) {
                    Button {
                        // TODO: 계정 비활성화
                    } label: {
                        Text("Deactivate Account")
                    }
                    .tint(.gray)
                    
                    Text("|")
                    
                    Button {
                        store.send(.view(.deleteAccountButtonTapped))
                    } label: {
                        Text("Delete Account")
                    }
                    .tint(.gray)
                }
                .padding()
            }
        }
        .task {
            await store.send(.view(.task)).finish()
        }
    }
    
    private var thickDivider: some View {
        Rectangle()
            .frame(height: 10)
            .foregroundStyle(.gray.opacity(0.3))
    }
    
    @ViewBuilder private func accountSection() -> some View {
        if case .loggedIn(let member) = store.authState {
            VStack(alignment: .leading, spacing: 12) {
                Text(member.nickname)
                    .font(.title2.bold())
                    .padding(.vertical, 8)
                
                Text("Signed up with")
                
                HStack {
                    Text(member.provider.identifier)
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.gray.opacity(0.1))
                        .strokeBorder(.gray)
                )
            }
            .padding()
        } else {
            Text("Please Sign in")
                .padding()
        }
    }
}

@Reducer
struct AnnouncementContentPreviewListFeature {
    enum SectionType {
        case notice, QNA
        
        var title: String {
            switch self {
            case .notice: "Notice"
            case .QNA: "Q&A"
            }
        }
        
        var emptyText: String {
            switch self {
            case .notice: "No notices at the moment."
            case .QNA: "No Q&As at the moment."
            }
        }
        
        var seeMoreButtonLabel: String { "See more" }
    }
    
    @ObservableState
    struct State: Equatable {
        let type: SectionType
        var contents: [AnnouncementItem]
    }
    
    enum Action {
        @CasePathable
        enum ViewAction {
            case seeMoreButtonTapped
        }
        
        @CasePathable
        enum Delegate {
            case seeMoreTapped(SectionType)
        }
        
        case view(ViewAction)
        case delegate(Delegate)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(.seeMoreButtonTapped):
                return .send(.delegate(.seeMoreTapped(state.type)))
                
            case .delegate:
                return .none
            }
        }
    }
}

struct AnnouncementContentPreviewListView: View {
    let store: StoreOf<AnnouncementContentPreviewListFeature>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(store.type.title)
                .font(.headline.bold())
            
            if store.contents.isEmpty {
                Text(store.type.emptyText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 100)
            } else {
                LazyVStack {
                    ForEach(store.contents) { content in
                        cell(content)
                        
                        if content.id != store.contents.last?.id {
                            Divider()
                        }
                    }
                    
                    if store.contents.count > 3 {
                        Button {
                            store.send(.view(.seeMoreButtonTapped))
                        } label: {
                            Text(store.type.seeMoreButtonLabel)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(.clear)
                                        .strokeBorder(.gray)
                                )
                        }
                        .tint(.black)
                    }
                }
            }
        }
        .padding()
    }
    
    @ViewBuilder private func cell(_ content: AnnouncementItem) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            AsyncDateView(date: content.createdAt, format: .ddMMMyy)
                .foregroundStyle(.gray)
            
            Text(content.content)
                .lineLimit(3)
        }
    }
}

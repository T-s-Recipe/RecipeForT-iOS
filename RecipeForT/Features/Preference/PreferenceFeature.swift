//
//  PreferenceFeature.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/12/25.
//

import SwiftUI

@MainActor
struct PreferenceFeature {
    struct Constants {
        static let providerGuidence = "Signed up with"
    }
    
    @Environment(\.router) private var router
    @Environment(MemberModel.self) private var memberModel
    
    @State private var state = PreferenceState()
}

// MARK: - ViewFeature Conformation
extension PreferenceFeature: ViewFeature {
    enum UIEvent {
        case task
    }
    
    func notify(_ event: UIEvent) {
        switch event {
        case .task:
            task()
        }
    }
}

// MARK: - View Conformation
extension PreferenceFeature: View {
    var body: some View {
        ScrollView(.vertical) {
            accountSection
            
            thickDivider
            
            AnnouncementContentPreviewListFeature(type: .notice, contents: state.announcements)
            
            thickDivider
            
            AnnouncementContentPreviewListFeature(type: .QNA, contents: state.inquiries)
            
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
                        // TODO: 회원탈퇴
                    } label: {
                        Text("Delete Account")
                    }
                    .tint(.gray)
                }
                .padding()
            }
        }
        .task {
            notify(.task)
        }
    }
    
    private var thickDivider: some View {
        Rectangle()
            .frame(height: 10)
            .foregroundStyle(.gray.opacity(0.3))
    }
    
    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(memberModel.user?.nickname ?? "Please Sign in")
                .font(.title2.bold())
                .padding(.vertical, 8)
            
            Text(Constants.providerGuidence)
            
            HStack {
                Text(memberModel.user?.provider.identifier ?? "Unknown Provider")
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
    }
}

// MARK: - Methods
private extension PreferenceFeature {
    func task() {
        // TODO: 공지사항, Q&A 가져오는 로직 추가
    }
}

// MARK: - Subviews
struct AnnouncementContentPreviewListFeature<Content: AnnouncementContent> {
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
    
    @Environment(\.router) private var router
    
    let type: SectionType
    let contents: [Content]
    
    init(type: SectionType, contents: [Content]) {
        self.type = type
        self.contents = contents
    }
}

// MARK: - ViewFeature Conformation
extension AnnouncementContentPreviewListFeature: ViewFeature {
    enum UIEvent {
        case seeMoreButtonTapped
    }
    
    func notify(_ event: UIEvent) {
        switch event {
        case .seeMoreButtonTapped:
            router.route(to: .loginView)
        }
    }
}

// MARK: - View Conformation
extension AnnouncementContentPreviewListFeature: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(type.title)
                .font(.headline.bold())
            
            if contents.isEmpty {
                Text(type.emptyText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 100)
            } else {
                LazyVStack {
                    ForEach(contents) { content in
                        cell(content)
                        
                        if content.id != contents.last?.id {
                            Divider()
                        }
                    }
                    
                    if contents.count > 3 {
                        Button {
                            notify(.seeMoreButtonTapped)
                        } label: {
                            Text(type.seeMoreButtonLabel)
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
    
    @ViewBuilder private func cell(_ content: Content) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(content.createdAt.toString(by: .ddMMMyy))
                .foregroundStyle(.gray)
            
            Text(content.content)
                .lineLimit(3)
        }
    }
}

#Preview {
    PreferenceFeature()
}

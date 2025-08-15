//
//  PreferenceFeature.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/12/25.
//

import SwiftUI

struct PreferenceFeature {
    enum Constants: String, CustomStringConvertible {
        case noticeSectionTitle = "Notice"
        case QNASectionTitle = "Q&A"
        
        var description: String { self.rawValue }
    }
    @Environment(\.router) private var router
    @Environment(\.memberRepository) private var memberRepository
    
    @State private var user: Member?
}

// MARK: - ViewFeature Conformation
extension PreferenceFeature: ViewFeature {
    enum UIEvent {
        case task
    }
    
    func notify(_ event: UIEvent) {
        switch event {
        case .task:
            switch memberRepository.authenticationState {
            case .loggedOut, .pendingRegistration:
                user = nil
            case .loggedIn(let member):
                user = member
            }
        }
    }
}

// MARK: - View Conformation
extension PreferenceFeature: View {
    var body: some View {
        ScrollView(.vertical) {
            accountSection
            
            thickDivider
            
            noticeSection(Constants.noticeSectionTitle.description)
            
            thickDivider
            
            noticeSection(Constants.QNASectionTitle.description)
            
            thickDivider
            
            HStack(spacing: 16) {
                Text("App version")
                Text("0.0.1")
            }
            .padding()
            
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
    
    private var thickDivider: some View {
        Rectangle()
            .frame(height: 10)
            .foregroundStyle(.gray.opacity(0.3))
    }
    
    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(user?.nickname ?? "Please Sign in")
                .font(.title2.bold())
                .padding(.vertical, 8)
            
            Text("Signed up with")
            
            HStack {
                Text(user?.provider.identifier ?? "Unknown Provider")
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
    
    @ViewBuilder
    private func noticeSection(_ title: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline.bold())
            
            cell()
            Divider()
            cell()
            Divider()
            cell()
            
            Button {
                router.route(to: .loginView)
            } label: {
                Text("See more")
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
        .padding()
    }
    
    @ViewBuilder private func cell() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("25.Jun.19")
                .foregroundStyle(.gray)
            
            Text("Lorem ipsum dolor sit amet consectetur. Dictumst pellentesque vivamus quam turpis faucibus in. Posuere sed aliquet et egestas leo lacinia non egestas leo lacinia")
                .lineLimit(3)
        }
    }
}

#Preview {
    PreferenceFeature()
}

//
//  PersonalView.swift
//  RecipeForT
//
//  Created by Swain Yun on 7/1/25.
//

import SwiftUI

struct PersonalView: View {
    @EnvironmentObject private var router: Router
    
    var body: some View {
        ScrollView(.vertical) {
            AccountSection()
            
            thickDivider
            
            NoticeSection(header: "Notice")
            
            thickDivider
            
            NoticeSection(header: "Q&A")
            
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
        .environmentObject(router)
    }
    
    private var thickDivider: some View {
        Rectangle()
            .frame(height: 10) 
            .foregroundStyle(.gray.opacity(0.3))
    }
}

// MARK: - Subviews
extension PersonalView {
    struct AccountSection: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("User ID")
                    .font(.title2.bold())
                    .padding(.vertical, 8)
                
                Text("Signed up with")
                
                HStack {
                    Text("Google")
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
    
    struct NoticeSection: View {
        @EnvironmentObject private var router: Router
        
        let header: String
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text(header)
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
}

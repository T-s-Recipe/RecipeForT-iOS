//
//  LoginFullScreenCover.swift
//  RecipeForT
//
//  Created by Swain Yun on 6/20/25.
//

import SwiftUI

struct LoginFullScreenCover: View {
    @EnvironmentObject private var router: Router
    @State private var navigationType: NavigationType?
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Spacer()
                    
                    Button {
                        router.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .padding([.top, .trailing], )
                    .tint(.black)
                }
                
                Spacer()
                
                VStack(spacing: 24) {
                    Image(.logo)
                        .padding(.bottom, 12)
                    
                    Button {
                        navigationType = .loginView(.signIn)
                    } label: {
                        Text("Log in")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical)
                            .background(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                    .tint(.white)
                    
                    Button {
                        navigationType = .loginView(.signUp)
                    } label: {
                        Text("Sign up for free")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical)
                            .background(
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(.white)
                                    .strokeBorder(.gray)
                            )
                    }
                    .tint(.black)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationDestination(item: $navigationType) { type in
                switch type {
                case .loginView(let sectionType):
                    LoginView(sectionType: sectionType)
                }
            }
        }
    }
}

// MARK: - Nested Types
extension LoginFullScreenCover {
    enum NavigationType: Hashable {
        case loginView(LoginView.SectionType)
    }
}

#Preview {
    LoginFullScreenCover()
        .environmentObject(Router())
}

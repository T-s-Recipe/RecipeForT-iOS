//
//  LoginView.swift
//  RecipeForT
//
//  Created by Swain Yun on 6/20/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var router: Router
    
    var body: some View {
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
                    // TODO: SignInView로 연결
                } label: {
                    Text("Log in")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                        .background(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }
                .tint(.white)
                
                Button {
                    // TODO: SignUpView로 연결
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
    }
}

#Preview {
    LoginView()
        .environmentObject(Router())
}

//
//  AuthFeature.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/11/25.
//

import SwiftUI

struct AuthFeature {
    enum Constants: String, CustomStringConvertible {
        case title = "Log in"
        case subtitle = "Welcome back !"
        
        var description: String { self.rawValue }
    }
    
    @Environment(\.router) private var router
    @Environment(MemberModel.self) private var memberModel: MemberModel
    
    @State private var isPendingRegistration: Bool = false
    @State private var floaterItem: FloaterItem?
}

// MARK: - ViewFeature Conformation
extension AuthFeature: ViewFeature {
    enum UIEvent {
        
    }
    
    func notify(_ event: UIEvent) {
        
    }
}

// MARK: - View Conformation
extension AuthFeature: View {
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
                if memberModel.isPendingRegistration {
                    SignUpFeature(floaterItem: $floaterItem)
                } else {
                    SignInFeature(floaterItem: $floaterItem)
                }
            }
            .padding(.horizontal)
            
            Spacer()
            Spacer()
        }
        .floater($floaterItem)
        .onChange(of: memberModel.isLoggedIn) { _, isLoggedIn in
            guard isLoggedIn else { return }
            router.dismiss()
        }
    }
}

#Preview {
    AuthFeature()
}

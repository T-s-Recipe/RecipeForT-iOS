//
//  LoginView.swift
//  RecipeForT
//
//  Created by Swain Yun on 6/22/25.
//

import SwiftUI
import AuthenticationServices
import GoogleSignIn
import Swinject

struct LoginView: View {
    @EnvironmentObject private var router: Router
    
    @State private var viewModel: LoginViewModel
    
    init(resolver: Resolver) {
        self.viewModel = LoginViewModel(resolver: resolver)
    }
    
    var body: some View {
        
    }
}

// MARK: - Subviews
extension LoginView {
    
    
    
}

#Preview {
    NavigationStack {
        LoginView(resolver: PreviewHelper.shared.resolver)
    }
    .environmentObject(PreviewHelper.shared.router)
}

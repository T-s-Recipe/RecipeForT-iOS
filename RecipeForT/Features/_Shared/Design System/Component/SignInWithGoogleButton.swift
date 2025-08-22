//
//  SignInWithGoogleButton.swift
//  RecipeForT
//
//  Created by Swain Yun on 8/6/25.
//

import SwiftUI
import GoogleSignIn

struct SignInWithGoogleButton: View {
    typealias Completion = (Result<GIDSignInResult, Error>) -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    enum Style {
        case signIn, signUp, `continue`
    }
    
    let style: Style
    let completion: Completion
    
    init(_ style: Style, completion: @escaping Completion) {
        self.style = style
        self.completion = completion
    }
    
    var body: some View {
        Button(action: {
            handleGoogleSignIn(completion)
        }) {
            HStack {
                Image("googleLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                
                Text(label)
                    .font(.system(size: 17, weight: .medium))
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(strokeColor, lineWidth: 1)
            )
        }
    }
    
    private var label: String {
        switch style {
        case .signIn: "Sign in with Google"
        case .signUp: "Sign up with Google"
        case .continue: "Continue with Google"
        }
    }
    
    private var backgroundColor: Color {
        switch colorScheme {
        case .dark: return .black
        case .light: return .white
        @unknown default: return .white
        }
    }
    
    private var foregroundColor: Color {
        switch colorScheme {
        case .dark: return .white
        case .light: return .black
        @unknown default: return .black
        }
    }
    
    private var strokeColor: Color {
        switch colorScheme {
        case .dark: return .clear
        case .light: return .black.opacity(0.7)
        @unknown default: return .black.opacity(0.7)
        }
    }
    
    private func handleGoogleSignIn(_ completion: @escaping Completion) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController
        else { return }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                completion(.failure(error))
                print("Google Sign-In error: \(error.localizedDescription)")
                return
            }
            
            guard let result else { return }
            completion(.success(result))
            print("Google Sign-In Success")
        }
    }
}

#Preview {
    SignInWithGoogleButton(.continue) { _ in
        
    }
}

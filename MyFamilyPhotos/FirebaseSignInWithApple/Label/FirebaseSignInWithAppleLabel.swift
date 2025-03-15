//
//  FirebaseSignInWithAppleLabel.swift
//
//
//  Created by Alex Nagy on 08.05.2024.
//

import SwiftUI

public struct FirebaseSignInWithAppleLabel: View {
    
    private let title: String
    
    /// Sign in with Apple label
    /// - Parameter title: title
    public init(_ title: String) {
        self.title = title
    }
    
    /// Sign in with Apple label
    /// - Parameter type: the title type
    public init(_ type: FirebaseSignInWithAppleLabelType) {
        switch type {
        case .signIn:
            title = "Sign in with Apple"
        case .signUp:
            title = "Sign up with Apple"
        case .continueWithApple:
            title = "Continue with Apple"
        case .signOut:
            title = "Sign out with Apple"
        case .deleteAccount:
            title = "Delete account with Apple"
        case .custom(let text):
            title = text
        }
    }
    
    public var body: some View {
        Label(title, systemImage: "applelogo")
            .buttonStyle(.plain)
            .padding(.leading, 20)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 44.0, alignment: .leading)
            .foregroundColor(.black)
            .background(.white)
            .cornerRadius(9)
            .multilineTextAlignment(.leading)
    }
}

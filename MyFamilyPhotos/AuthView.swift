//
//  AuthView.swift
//  MyFamilyPhotos
//
//  Created by Larry Shannon on 3/13/25.
//

import SwiftUI

struct AuthView: View {
    @Environment(\.firebaseSignInWithApple) private var firebaseSignInWithApple
    
    var body: some View {
        ZStack {
            Color("Background-grey").edgesIgnoringSafeArea(.all)
            VStack {
                FirebaseSignInWithAppleButton {
                    FirebaseSignInWithAppleLabel(.signIn)
                }
                .padding([.leading, .trailing], 20)
            }
        }
    }
}

#Preview {
    AuthView()
}

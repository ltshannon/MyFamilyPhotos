//
//  SettingsView.swift
//  MyFamilyPhotos
//
//  Created by Larry Shannon on 3/14/25.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        ZStack {
            Color("Background-grey").edgesIgnoringSafeArea(.all)
            VStack {
                FirebaseSignOutWithAppleButton {
                    FirebaseSignInWithAppleLabel(.signOut)
                }
                FirebaseDeleteAccountWithAppleButton {
                    FirebaseSignInWithAppleLabel(.deleteAccount)
                }
                Spacer()
            }
            .padding([.leading, .trailing], 20)
        }
    }
}

#Preview {
    SettingsView()
}

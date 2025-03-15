//
//  ViewModifiers.swift
//  MyFamilyPhotos
//
//  Created by Larry Shannon on 3/14/25.
//

import SwiftUI

struct DefaultTextButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(.white)
            .frame(height: 55)
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .cornerRadius(10)
            .padding([.leading, .trailing])
    }
}

extension View {
    func DefaultTextButtonStyle() -> some View {
        modifier(DefaultTextButton())
    }
    
}


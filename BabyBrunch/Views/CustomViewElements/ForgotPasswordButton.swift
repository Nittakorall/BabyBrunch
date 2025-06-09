//
//  ForgotPasswordButton.swift
//  BabyBrunch
//
//  Created by KiwiComp on 2025-05-23.
//

import SwiftUI

struct ForgotPasswordButton: View {
    let action : () -> Void
    var body: some View {
        Button(action: action) {
            Text("Forgot password?")
                .foregroundColor(.black)
                .underline()
                .frame(width: 250, height: 1)
                .padding()
        }
    }
}



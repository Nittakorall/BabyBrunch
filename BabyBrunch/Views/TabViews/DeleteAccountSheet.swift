//
//  DeleteAccountSheet.swift
//  BabyBrunch
//
//  Created by Simon Elander on 2025-05-23.
//

import SwiftUI
import ConfettiSwiftUI

struct DeleteAccountSheet: View {
    @Binding var showDeletedAccountSheet: Bool
    @State var password = ""
    @EnvironmentObject private var authVM: AuthViewModel
    
    //confetti trigger
    // ───────────────────────────────────────────
    @State private var confetti: Int = 0
    @State private var deletionInFlight = false
    // ───────────────────────────────────────────
    
    var body: some View {
        Text("Password")
        //password input field
        CustomTextField(input: $password, hint: "Password", type: .password)
        CustomButton(label: "Delete", backgroundColor: "raisinBlack", width: 200) {
            // prevent double-taps when confetti anim plays
            guard !deletionInFlight else { return }
            deletionInFlight = true
            
            confetti += 1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                authVM.deleteUser(password: password) { success in
                    if success{
                        authVM.isLoggedIn = false
                    } else{
                        print ("Account deletion failed")
                    }
                }
            }
        }
        .disabled(deletionInFlight)                // Grays out the button
        .confettiCannon(trigger: $confetti)
        .padding(.bottom, 50)
    }
}

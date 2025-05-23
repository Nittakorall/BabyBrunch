//
//  DeleteAccountSheet.swift
//  BabyBrunch
//
//  Created by Simon Elander on 2025-05-23.
//

import SwiftUI

struct DeleteAccountSheet: View {
    @Binding var showDeletedAccountSheet: Bool
    @State var password = ""
    @EnvironmentObject private var authVM: AuthViewModel
    
    var body: some View {
        Text("Password")
        //password input field
        CustomTextField(input: $password, hint: "Password", type: .password)
        CustomButton(label: "Delete", backgroundColor: "raisinBlack", width: 200) {
            authVM.deleteUser(password: password) { success in
                if success{
                    authVM.isLoggedIn = false
                } else{
                    print ("shit out of luck")
                }
            }
        }.padding(.bottom, 50)
    }
}

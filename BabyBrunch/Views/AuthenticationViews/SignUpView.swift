//
//  SignUpView.swift
//  BabyBrunch
//
//  Created by Victor Sundberg on 2025-05-19.
//

import SwiftUI
import FirebaseAuth

struct SignUpView: View {
   
   @State private var email: String = ""
   @State private var password: String = ""
   @State private var confirmPassword: String = ""
   @EnvironmentObject private var authVM : AuthViewModel
   
   var body: some View {
      //background
      ZStack{
         Color("lavenderBlush")
            .ignoresSafeArea()
         //logo
         VStack{
            CustomTitle(title: "BABYBrunch")
            VStack(alignment: .leading, spacing: 20) {
               Text("Email")
               
               //email input field
                CustomTextField(input: $email, hint: "Email", type: .email)
               
               Text("Password")
               //password input field
               CustomTextField(input: $password, hint: "Password", type: .password)
               
               Text("Confirm password")
               //password confirmation field
               CustomTextField(input: $confirmPassword, hint: "Confirm Password", type: .password)
               
               CustomButton(label: "Register", backgroundColor: "oldRose", width: 250) {
                  register()
               }.padding(.top, 70)
            }
            
            //white space in the middle of the screen
            .padding()
            .frame(maxHeight: .infinity, alignment: .top)
            .frame(width: 300, height: 500)
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
               RoundedRectangle(cornerRadius: 10)
                  .stroke(Color.black, lineWidth: 1)
            )
         }
         //MARK: alerts are handled here:
         .alert(item: $authVM.authError) {
            err in
            Alert(title: Text("Error"), message: Text(err.localizedDescription), dismissButton: .default(Text("OK")){ authVM.authError = nil })
         }
         
         .frame(maxHeight: .infinity, alignment: .top)
      }
      
   }
   
   // guard sections can be removed if we do not want frontend to handle these error alerts. When removed, the '.alert' above will display errors from the firebase server instead
   func register() {
      guard !email.isEmpty else {
         authVM.authError = .emailEmpty
         return
      }
      guard password.count >= 6 else {
         authVM.authError = .passwordTooShort
         return
      }
      guard password == confirmPassword else {
         authVM.authError = .passwordMismatch
         return
      }
      authVM.signUpWithEmail(email: email, password: password){ success in
         if success{
            authVM.signIn(email: email, password: password)
         } else {
            if authVM.authError == nil {
               assertionFailure("signUpWithEmail returned false with no authError") //will not display to the user, only shows up in the log. ⚠️⚠️⚠️ This will crash the app when debugging (running the simulation), that is intended
            }
         }
      }
      
   }
   
}

//struct SignUpView_Previews: PreviewProvider {
//    static var previews: some View {
//        SignUpView(isSignedUp: .init(get: { true }, set: { _ in }))
//    }
//}

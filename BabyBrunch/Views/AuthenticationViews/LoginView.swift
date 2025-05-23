//
//  LoginView.swift
//  BabyBrunch
//
//  Created by Victor Sundberg on 2025-05-19.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
   @State private var email: String = ""
   @State private var password: String = ""
   @State private var isChecked = false
   @State private var error_: String?
   @EnvironmentObject private var authVM: AuthViewModel
   @State private var openSignUpView = false
   
   var body: some View {
      
      ZStack{
         //background color
         Color(.lavenderBlush)
            .ignoresSafeArea()
         VStack{
            VStack{
               // logo
               CustomTitle(title: "BABYBrunch")
               VStack(alignment: .leading, spacing: 20) {
                  
                  Text("Email")
                  //Email input field
                  CustomTextField(input: $email, hint: "Email", type: .normal)
                  
                  Text("Password")
                  //password input field
                  CustomTextField(input: $password, hint: "Password", type: .password)
                  
                  Toggle(isOn: $isChecked) {
                     Text("Keep me signed in")
                  }.tint(Color(.thistle))

                  // Sign in button.
                  CustomButton(label: "SignIn", backgroundColor: "oldRose", width: 250) {
                     // guard code block can be removed if we only want errors to be handled server side. This one displays an error if the email field is empty (without it it will display "Please enter a functional email address" instead)
                     guard !email.isEmpty else {
                        authVM.authError = .emailEmpty
                        return
                     }
                     authVM.signIn(email: email, password: password)
                  }
                  //forgot password button
                  ForgotPasswordButton(action: {
                     // Action code here.
                  }).padding(.top, 50)
                  
               }
               //white field in the middle of the screen
               .padding()
               .frame(maxHeight: .infinity, alignment: .top)
               .frame(width: 300, height: 450)
               .background(Color.white)
               .cornerRadius(10)
               .overlay(
                  RoundedRectangle(cornerRadius: 10)
                     .stroke(Color.black, lineWidth: 1))
            }
            .frame(maxHeight: .infinity, alignment: .top)
            
            //MARK: sign in as guest button
            CustomButton(label: "Sign In as Guest", backgroundColor: "thistle", width: 250) {
               authVM.signInAsGuest()
            }
            
            // Move to register sheet.
            CustomButton(label: "Register", backgroundColor: "oldRose", width: 250) {
               openSignUpView = true
            }
            .sheet(isPresented: $openSignUpView) {
               SignUpView()
            }
            //MARK: alerts are handled here:
            .alert(item: $authVM.authError) {
               err in
               Alert(title: Text("Error"), message: Text(err.localizedDescription), dismissButton: .default(Text("OK")){ authVM.authError = nil })
            }
         }
         
      }
      
      
   }
   
   struct LoginView_Previews: PreviewProvider {
      static var previews: some View {
         LoginView()
      }
   }
   
}

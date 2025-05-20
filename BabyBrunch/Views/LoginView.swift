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
    @State var isSignedUp = false
    @State private var error_: String?
    
    var body: some View {
        
        ZStack{
            
            //background color
            Color("lavenderBlush")
                .ignoresSafeArea()
            
            VStack{
                
                /// logo
                Text("BABYBrunch")
                    .padding(.top, 50)
                    .padding(.bottom, 50)
                    .fontDesign(.rounded)
                    .font(.title)
                    .foregroundColor(Color("oldRose"))
                VStack(alignment: .leading, spacing: 20) {
                    
                    Text("Email")
                    //Email input field
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color("raisinBlack"), lineWidth: 2)
                        )
                        .background(Color.white)
                        .cornerRadius(8)
                    
                    
                    Text("Password")
                    //password input field
                    SecureField("Password", text: $password)
                    
                        .textContentType(.password)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color("raisinBlack"), lineWidth: 2)
                        )
                        .background(Color.white)
                        .cornerRadius(8)
                    Toggle(isOn: $isChecked) {
                        Text("Keep me signed in")
                    }
                    .tint(Color("thistle"))
                    
                    
                    //sign in button
                    Button("Sign In") {
                        signIn()
                    }
                    .foregroundColor(.white)
                    .frame(width: 250, height: 10)
                    .padding()
                    .background(Color("oldRose"))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 1)
                    )
                    
                    //forgot password button
                    Button(action: {
                        
                    }) {
                        Text("Forgot password?")
                            .foregroundColor(.black)
                            .underline()
                            .frame(width: 250, height: 1)
                            .padding()
                    }
                    .padding(.top, 50)
                    
                    
                }
                
                //white field in the middle of the screen
                .padding()
                .frame(maxHeight: .infinity, alignment: .top)
                .frame(width: 300, height: 450)
                .background(Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 1)                   )
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        
    }
    
    func signIn() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let err = error {
                error_ = err.localizedDescription
                print("Sign in failed: \(err)")
            } else {
                isSignedUp = true
            }
        }
    }
    
}

//struct LoginView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginView()
//    }
//}

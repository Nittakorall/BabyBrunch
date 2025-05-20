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
    @State private var error_: String?
    @State private var isSignedUp = false
    
    
    var body: some View {
        //background
        ZStack{
            Color("lavenderBlush")
                .ignoresSafeArea()
            //logo
            VStack{
                Text("BABYBrunch")
                    .padding(.top, 50)
                    .padding(.bottom, 50)
                    .fontDesign(.rounded)
                    .font(.title)
                    .foregroundColor(Color("oldRose"))
                VStack(alignment: .leading, spacing: 20) {
                    
                    Text("Email")
                    
                    //email input field
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
                    
                    Text("Confirm password")
                    //password confirmation field
                    SecureField("Confirm password", text: $confirmPassword)
                    
                        .textContentType(.password)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color("raisinBlack"), lineWidth: 2)
                        )
                        .background(Color.white)
                        .cornerRadius(8)
                    
                    //Sign up button
                    Button("register") {
                        register()
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
                    .padding(.top, 70)
                    
                    
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
            .frame(maxHeight: .infinity, alignment: .top)
        }
        
    }
    
    func register() {
        guard !email.isEmpty, !password.isEmpty else {
            error_ = "email & password, tack"
            return
        }
        guard password.count >= 6 else {
            error_ = "6 tecken pga. Firebase restrictions"
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let err = error {
                error_ = "Fel vid registrering: \(err.localizedDescription)"
            } else {
                isSignedUp = true
            }
        }
    }
    
}

//struct SignUpView_Previews: PreviewProvider {
//    static var previews: some View {
//        SignUpView(isSignedUp: .init(get: { true }, set: { _ in }))
//    }
//}

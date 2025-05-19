//
//  SignUpView.swift
//  BabyBrunch
//
//  Created by Victor Sundberg on 2025-05-19.
//

import SwiftUI

struct SignUpView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    
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
                    Button("Sign Up") {
                        
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
    
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}

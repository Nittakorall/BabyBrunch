//
//  LoginView.swift
//  BabyBrunch
//
//  Created by Victor Sundberg on 2025-05-19.
//

import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
       @State private var password: String = ""
       @State private var isChecked = false
      
       var body: some View {
          
           ZStack{
               Color("lavenderBlush")
                   .ignoresSafeArea()
              
               VStack{
                   Text("BABYBrunch")
                       .padding(.top, 50)
                       .padding(.bottom, 50)
                       .fontDesign(.rounded)
                       .font(.title)
                       .foregroundColor(Color("oldRose"))
                   VStack(alignment: .leading, spacing: 20) {
                      
                       Text("Email")
                      
                       TextField("Email", text: $email)
                           .keyboardType(.emailAddress)
                           .textContentType(.emailAddress)
                           .autocapitalization(.none)
                           .disableAutocorrection(true)
                           .padding()
                           .overlay(
                               RoundedRectangle(cornerRadius: 10)
                                   .stroke(Color("raisinBlack"), lineWidth: 2) //check how to make borderRadius
                           )
                           .background(Color.white)
                           .cornerRadius(8)
                      
                      
                       Text("Password")
                      
                       SecureField("Password", text: $password)
                      
                           .textContentType(.password)
                           .padding()
                           .overlay( // Красивая граница со скруглением
                               RoundedRectangle(cornerRadius: 10)
                                   .stroke(Color("raisinBlack"), lineWidth: 2) //check how to make borderRadius
                           )
                           .background(Color.white)
                           .cornerRadius(8)
                       Toggle(isOn: $isChecked) {
                           Text("Keep me signed in")
                       }
                       .tint(Color("thistle"))
                       Button("Sign In") {
                          
                       }
                       .foregroundColor(.white)
                       .frame(width: 250, height: 10)
                       .padding()
                       .background(Color("oldRose"))
                       .cornerRadius(10)
                       .overlay( // Красивая граница со скруглением
                           RoundedRectangle(cornerRadius: 10)
                               .stroke(Color.black, lineWidth: 1) //check how to make borderRadius
                       )
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
                  
                  
                   .padding()
                   .frame(maxHeight: .infinity, alignment: .top)
                   .frame(width: 300, height: 450)
                   .background(Color.white)
                   .cornerRadius(10)
                   .overlay( // Красивая граница со скруглением
                       RoundedRectangle(cornerRadius: 10)
                           .stroke(Color.black, lineWidth: 1) //check how to make borderRadius
                   )
               }
               .frame(maxHeight: .infinity, alignment: .top)
           }
    
       }

   }

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

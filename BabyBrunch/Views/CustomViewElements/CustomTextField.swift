//
//  CustomTextField.swift
//  BabyBrunch
//
//  Created by KiwiComp on 2025-05-23.
//

import SwiftUI

struct CustomTextField: View {
   
   @Binding var input : String
   let hint : String
   let type : TextFieldType
   @State var isSecure = true
   
    var body: some View {
       HStack {
          if type == .password {
             if isSecure {
                SecureField(hint, text: $input)
                   .textContentType(.password)
             } else {
                TextField(hint, text: $input)
                   .textContentType(.password)
             }
             Button(action: {isSecure.toggle()}) {
                Image(systemName: isSecure ? "eye.slash" : "eye")
                   .foregroundColor(Color(.raisinBlack))
             }
          } else {
             TextField(hint, text: $input)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
             if !input.isEmpty {
                Button(action: { input = ""}) {
                   Image(systemName: "xmark.circle.fill")
                      .foregroundColor(Color(.raisinBlack))
                }
             }
          }
       }
       .padding()
       .overlay(
           RoundedRectangle(cornerRadius: 10)
            .stroke(Color(.raisinBlack), lineWidth: 2)
       )
       .background(Color.white)
       .cornerRadius(8)
       .autocapitalization(.none)
       .disableAutocorrection(true)
    }
}

enum TextFieldType {
   case normal, password
}


//#Preview {
//    CustomTextField()
//}

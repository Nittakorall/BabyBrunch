//
//  DarkButton.swift
//  BabyBrunch
//
//  Created by KiwiComp on 2025-05-23.
//

import Foundation
import SwiftUI

struct CustomButton : View {
   let label : String
   let backgroundColor : String
   let width : CGFloat
   let action : () -> Void
   
   var body : some View {
      Button(action: action) {
         Text(label)
            .foregroundColor(.white)
            .frame(width: width, height: 10)
            .padding()
            .background(Color(backgroundColor))
            .cornerRadius(10)
            .overlay(
               RoundedRectangle(cornerRadius: 10)
                  .stroke(Color.black, lineWidth: 1)
            )
      }
   }
}




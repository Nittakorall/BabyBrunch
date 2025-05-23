//
//  ProfileView.swift
//  BabyBrunch
//
//  Created by test2 on 2025-05-19.
//

import SwiftUI

struct ProfileView: View {
   @EnvironmentObject private var authVM: AuthViewModel
   
   var body: some View {
      ZStack{
         Color("lavenderBlush")
            .ignoresSafeArea()
         VStack{
            CustomTitle(title: "My Profile")
            Spacer()
            CustomButton(label: "Sign Out", backgroundColor: "oldRose", width: 200) {
               authVM.signOut()
            }.padding(.bottom, 50)
         }
      }
   }
}

#Preview {
   ProfileView()
}

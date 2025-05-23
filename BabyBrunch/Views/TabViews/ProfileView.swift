//
//  ProfileView.swift
//  BabyBrunch
//
//  Created by test2 on 2025-05-19.
//

import SwiftUI

struct ProfileView: View {
   @EnvironmentObject private var authVM: AuthViewModel
   @State var showDeletedAccountSheet = false
    
   var body: some View {
       ZStack{
           Color("lavenderBlush")
               .ignoresSafeArea()
           VStack{
               CustomTitle(title: "My Profile")
               Spacer()
               CustomButton(label: "Sign Out", backgroundColor: "oldRose", width: 200) {
                   authVM.signOut()
               }.padding(.bottom, 20)
               
               CustomButton(label: "Delete", backgroundColor: "raisinBlack", width: 200) {
                   showDeletedAccountSheet = true
               }.padding(.bottom, 50)
                   
           }
           .sheet(isPresented: $showDeletedAccountSheet, content: {
               DeleteAccountSheet(showDeletedAccountSheet: $showDeletedAccountSheet)
           })
      }
   }
}

//#Preview {
//   ProfileView()
//}

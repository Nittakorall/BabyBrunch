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
                
                HStack{
                    Text("My profile")
                    
                }
                .padding(.top, 20)
                .fontDesign(.rounded)
                .font(.title)
                .foregroundColor(Color("oldRose"))
                Spacer()
                Button(action: {
                    authVM.signOut()
                }) {
                    Text("Sign Out")
                        .foregroundColor(.white)
                        .frame(width: 200, height: 10)
                        .padding()
                        .background(Color("oldRose"))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 1)
                        )
                }
                Button(action: {
                    
                }) {
                    Text("Delete Account")
                        .foregroundColor(.white)
                        .frame(width: 200, height: 10)
                        .padding()
                        .background(Color(.raisinBlack))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 1)
                        )
                }
                .padding(.bottom, 50)
                
                
            }
        }
    }
    
}
#Preview {
    ProfileView()
}

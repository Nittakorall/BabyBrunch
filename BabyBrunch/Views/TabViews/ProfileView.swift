//
//  ProfileView.swift
//  BabyBrunch
//
//  Created by test2 on 2025-05-19.
//

import SwiftUI
import ConfettiSwiftUI

struct ProfileView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @State var showDeletedAccountSheet = false
    @AppStorage("isDarkMode") private var isDarkMode = false
    @ObservedObject var locVM : LocationViewModel
    @State private var showAlert = false
    
    //confetti trigger
    @State private var confetti: Int = 0
    
    var body: some View {
        ZStack{
            Color("lavenderBlush")
                .ignoresSafeArea()
            VStack{
                CustomTitle(title: "My Profile")
                
                Spacer()
                Toggle("Dark Mode", isOn: $isDarkMode)
                    .foregroundColor(.colorText)
                    .tint(Color("oldRose"))
                    .padding(.horizontal, 50)
                    .padding(.bottom, 20)
                
                CustomButton(label: "Settings", backgroundColor: "oldRose", width: 200) {
                    showAlert = true
                }.padding(.bottom, 20)
                    .alert("Enable Location", isPresented: $showAlert){
                        Button("OK"){
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                                UIApplication.shared.open(url)
                                            }
                            print("Enabled")
                        }
                        Button("Cancel", role: .cancel){}
                    } message: {
                        Text("Press ok to get to settings -> Click on app -> Enable location")
                    }
                
                // Confettk Button
                CustomButton(label: "Confetti!", backgroundColor: "oldRose", width: 200) {
                    confetti += 1
                }
                .padding(.bottom, 20)
                .confettiCannon(trigger: $confetti)
                
                Spacer()
                CustomButton(label: "Sign Out", backgroundColor: "oldRose", width: 200) {
                    authVM.signOut()
                }.padding(.bottom, 20)
                .confettiCannon(trigger: $confetti)

                
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
//    ProfileView(
//}

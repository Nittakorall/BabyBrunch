//
//  ContentView.swift
//  BabyBrunch
//
//  Created by Kseniia on 2025-05-14.
//

import SwiftUI

struct ContentView: View {
    @State private var isActive = false
    var body: some View {
        ZStack {
            if isActive {
                LoginView()
            } else {
                SplashScreen(isActive: $isActive)
            }
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

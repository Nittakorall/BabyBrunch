//
//  SplashScreen.swift
//  BabyBrunch
//
//  Created by test2 on 2025-06-02.
//

import SwiftUI
import AVFoundation

struct SplashScreen: View {
    @State private var isAnimating = false
    @Binding var isActive: Bool
    @ObservedObject var soundVM = SoundViewModel()
    

    var body: some View {
        ZStack {
            Color("lavenderBlush")
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                CustomTitle(title: "BABYBrunch")
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .animation(.easeOut(duration: 1.0).delay(0.5), value: isAnimating)
              
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .onAppear {
            isAnimating = true
         //   player?.play()
            // shows 2 minutes then proceed to another views
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                soundVM.playSound(resourceName: "SplashScreenSound", resourceFormat: "wav")
                withAnimation {
                    isActive = true
                }
            }
        }
    }
    
}


//#Preview {
//    SplashScreen(isActive: true)
//}

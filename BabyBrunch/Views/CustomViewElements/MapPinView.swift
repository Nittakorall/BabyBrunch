//
//  MapPinView.swift
//  BabyBrunch
//
//  Created by Simon Elander on 2025-05-22.
//

import SwiftUI

struct MapPinView: View {
    let accentColor = Color(.babyBlue)
    
    var body: some View {
        VStack(spacing: 0){
            Image(systemName: "fork.knife.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .font(.headline)
                .foregroundColor(Color(.white))
                .padding(4)
                .background(accentColor)
                .cornerRadius(36)
            
            Image(systemName: "triangle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 10, height: 10)
                .rotationEffect(.degrees(180))
                .foregroundColor(accentColor)
                .offset(y:-2)
                .padding(.bottom,40)
                
        }
        //.background(Color.blue) to make the triangle point to the tap location instead of the whole symbol covering it.
    }
}

struct MapPinView_Previews: PreviewProvider {
    static var previews: some View {
            MapPinView()
    }
}

//
//  AddReviewView.swift
//  BabyBrunch
//
//  Created by test2 on 2025-05-25.
//

import SwiftUI

struct AddReviewView: View {
    
    
    @State private var selectedOption = "⭐️"
    
    let stars = ["⭐️", "⭐️⭐️", "⭐️⭐️⭐️", "⭐️⭐️⭐️⭐️", "⭐️⭐️⭐️⭐️⭐️"]
    
    
    
    var body: some View {
        ZStack {
            Color("lavenderBlush")
                .edgesIgnoringSafeArea(.all)
            VStack {
                
                HStack {
                    Text("Rate your experience:")
                    Spacer()
                    Picker("How do you get this one???",selection: $selectedOption) {
                        ForEach(stars, id: \.self) {star in
                            Text(star)
                        }
                    }
             
                }
                .frame(width: 350, height: 100)
                .background(Color.white)
                
                .padding(.horizontal, 20)
                .padding(.top, 50)
                
                
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
    //    .frame(maxHeight: .infinity, alignment: .top)
    }
    
}

#Preview {
    AddReviewView()
}

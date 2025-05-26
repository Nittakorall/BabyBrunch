//
//  AddReviewView.swift
//  BabyBrunch
//
//  Created by test2 on 2025-05-25.
//

import SwiftUI

struct AddReviewView: View {
    
    
    
    @State private var amounntStars = "⭐️⭐️⭐️"
    let stars = ["⭐️", "⭐️⭐️", "⭐️⭐️⭐️", "⭐️⭐️⭐️⭐️", "⭐️⭐️⭐️⭐️⭐️"]
    
    @State private var reviewText = ""
    
    
    var body: some View {
        ZStack {
            Color("lavenderBlush")
                .edgesIgnoringSafeArea(.all)
            VStack {
                
                
                //ui for picker with stars, functional but will be replaced
                //                HStack {
                //                    Text("Rate your experience:")
                //                        .padding(.horizontal, 10)
                //                    Spacer()
                //                    Picker("How do you get this one???",selection: $amounntStars) {
                //                        ForEach(stars, id: \.self) {star in
                //                            Text(star)
                //                        }
                //                    }
                //                }
                //                .frame(width: 350, height: 100)
                //                .background(Color.white)
                //                .overlay(
                //                    RoundedRectangle(cornerRadius: 10)
                //                        .stroke(Color(.raisinBlack), lineWidth: 2)
                //                )
                //                .padding(.horizontal, 20)
                //                .padding(.top, 50)
                
                
                
                //add review field
                VStack{
                    Text("Add your review:")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 10)
                        .padding(.top, 20)
                    TextEditor(text: $reviewText)
                    
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(.thistle), lineWidth: 2)
                        )
                        .padding(.horizontal, 10)
                        .padding(.vertical, 20)
                }
                
                .frame(width: 350, height: 400)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.raisinBlack), lineWidth: 2)
                )
                .padding(.top, 50)
                
                
                //button "add review"
                CustomButton(label: "Add review", backgroundColor: "oldRose", width: 350) {
                    
                }
                .padding(.top, 50)
            }
            
            .frame(maxHeight: .infinity, alignment: .top)
        }
        
    }
    
}


#Preview {
    AddReviewView()
}

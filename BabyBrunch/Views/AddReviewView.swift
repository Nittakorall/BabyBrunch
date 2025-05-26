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
   @State var rating = 0
    
    
    var body: some View {
        ZStack {
            Color("lavenderBlush")
                .edgesIgnoringSafeArea(.all)
            VStack {
                
               CustomTitle(title: "Choose a star rating:")
               StarRatingView(rating: $rating)
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

struct StarRatingView: View {
   @Binding var rating: Int
   
   var body: some View {
      HStack {
         // For each number 1-5:
         ForEach(1...5, id: \.self) { index in
            Image(systemName: index <= rating ? "star.fill" : "star")
            // Gradient colour instead of one colour.
               .foregroundStyle( index <= rating ?
                     AnyShapeStyle(LinearGradient(colors: [Color(.lightYellowStar), Color(.darkYellowStar)], startPoint: .top, endPoint: .bottom)) :
                     AnyShapeStyle(.gray))
               .font(.system(size: 30)) // Size of stars.
               .offset(y: index <= rating ? -10 : 0) // Move stars up on y-axis.
               .shadow(color: .black.opacity(0.3), radius: 3, x: -2, y: 5) // Shadow around image for more 3D effect.
               .scaleEffect(index == rating ? 1.3 : 1.0) // Upon click, enlarge star slightly.
               .animation(.spring(), value: rating) // Upon click, animate when star get larger.
               // When a star is clicked, set its index to our rating variable.
               .onTapGesture {
                  rating = index
                  print("Rating: \(rating)")
               }
         }
      }
   }
}

#Preview {
    AddReviewView()
}

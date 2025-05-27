//
//  VenueDetailView.swift
//  BabyBrunch
//
//  Created by test2 on 2025-05-20.
//

import SwiftUI

struct VenueDetailView: View {
    
    let pin: Pin
   // var reviews = ["A W E S O M E", "best cafe ever my baby looooved it!", "Nah too expensive blablablablablablablablablablablablabla"]
    
    @State var addReviewSheet = false
    
    var body: some View {
        ZStack{
            // Background color
            Color("lavenderBlush")
                .edgesIgnoringSafeArea(.all) // lets ignore safe area and place Image up there
            
            // VStack for venueImage
            VStack{
                Image("venue")
                    .resizable()
                    .aspectRatio(contentMode: .fill) // fills available width
                    .frame(width: UIScreen.main.bounds.width, height: 250) // changes height
                    .padding(.bottom, 20)
                
                
                //Vstack for vanue information
                VStack{
                    StarsView(rating : pin.averageRating)
                    Text(pin.name)
                        .foregroundColor(Color(.oldRose))
                        .font(.custom("Beau Rivage", size: 40)) // Don't know how to add custom fonts, I'll fix later
                    
                    Text("Address")
                        .foregroundColor(Color(.oldRose))
                        .fontDesign(.rounded)
                    Text(pin.phoneNumber)
                        .foregroundColor(Color(.oldRose))
                        .fontDesign(.rounded)
                    Text("email@example.com")
                        .foregroundColor(Color(.oldRose))
                    VStack{
                        HStack{
                            Text("Your rating:")
                            Text("\u{2B50} \u{2B50} \u{2B50} \u{2B50}")
                                
                        }
                        Text("Your wonderful reviewYour wonderful reviewYour wonderful reviewYour wonderful reviewYour wonderful reviewYour wonderful reviewYour wonderful reviewYour wonderful reviewYour wonderful reviewYour wonderful reviewYour wonderful reviewYour wonderful reviewYour wonderful reviewYour wonderful review")
                    }
                    .padding()
                    .background(Color(.thistle)) 
                    .cornerRadius(12)
                    .padding()
                    
                    CafeCarouselView()
                    
                    
                    //  Spacer()
                    Button("Rate venue") {
                        addReviewSheet = true
                    }
                    .foregroundColor(.white)
                    .frame(width: 250, height: 10)
                    .padding()
                    .background(Color("oldRose"))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 1)
                        
                    )
                    .padding(.bottom, 40)
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .ignoresSafeArea()
        }
        .sheet(isPresented: $addReviewSheet) {
            AddReviewView(pin: pin)
                .presentationDetents([.fraction(0.3), .fraction(0.6), .large])
        }
    }
    
}

//#Preview {
//    VenueDetailView()
//}

struct StarsView: View {
    var rating : Double
    var body: some View {
        VStack{
            //better be moved so separate subview later
            if rating < 2.0 {
                Text("\u{2B50}")
            } else if rating < 3.0 {
                Text("\u{2B50} \u{2B50}")
            } else if rating < 4.0 {
                Text("\u{2B50} \u{2B50} \u{2B50}")
            } else if rating < 5.0 {
                Text("\u{2B50} \u{2B50} \u{2B50} \u{2B50}")
            } else if rating == 5.0 {
                Text("\u{2B50} \u{2B50} \u{2B50} \u{2B50} \u{2B50}")
            }
        }
    }
}


struct CafeCarouselView: View {
    let reviews: [Review] = [
        Review(userName: "Ella", rating: 3, review: "fy aldrig igen"),
       Review(userName: "Bob", rating: 4.5, review: "good enough"),
       Review(userName: "Patricia", rating: 5, review: "awesomeawesomeawesomeawesomeawesomeawesomeawesomeawesomeawesomeawesomeawesomeawesomeawesomeawesomeawesomeawesomeawesomeawesomeawesomeawesomeawesomeawesomeawesomeawesomeawesomeawesomeawesomeawesomeawesomeawesomeawesomeawesomeawesomeawesomeawesomeawesomeawesomeawesomeawesomeawesomeawesomeawesomeawesomeawesomeawesomeawesomeawesomeawesomeawesomeawesomeawesomeawesomeawesome")
    ]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(reviews) { review in
                   CardView(review: review)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

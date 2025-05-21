//
//  VenueDetailView.swift
//  BabyBrunch
//
//  Created by test2 on 2025-05-20.
//

import SwiftUI

struct VenueDetailView: View {
    
    var rating: Double = 5.0
    var reviews = ["A W E S O M E", "best cafe ever my baby looooved it!", "Nah too expensive blablablablablablablablablablablablabla"]
    
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
                    StarsView(rating : rating)
                    Text("Name of Venue")
                        .foregroundColor(Color(.oldRose))
                        .font(.custom("Beau Rivage", size: 40)) // Don't know how to add custom fonts, I'll fix later
                    
                    Text("Address")
                        .foregroundColor(Color(.oldRose))
                        .fontDesign(.rounded)
                    Text("Phone Number")
                        .foregroundColor(Color(.oldRose))
                        .fontDesign(.rounded)
                    Text("email@example.com")
                        .foregroundColor(Color(.oldRose))
                    
                    ReviewListView(reviews : reviews)
                    
                    
                    //  Spacer()
                    Button("Rate venue") {
                        
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
        
    }
}

#Preview {
    VenueDetailView()
}

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

struct ReviewListView: View {
    var reviews : [String]
    var body: some View {
        List() {
            ForEach(reviews, id: \.self) { review in
                VStack{
                    HStack{
                        Text(review)
                        Spacer()
                        Text("4.6")
                        
                    }
                }
            }
            .listRowBackground(Color("lavenderBlush"))
        }
        .scrollContentBackground(.hidden)
        
    }
}

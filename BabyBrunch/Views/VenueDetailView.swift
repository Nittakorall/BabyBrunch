//
//  VenueDetailView.swift
//  BabyBrunch
//
//  Created by test2 on 2025-05-20.
//

import SwiftUI
import MapKit

struct VenueDetailView: View {
    
    let pin: Pin
    let mapViewRef: MKMapView?
    @StateObject var mapVM = MapViewModel()
    
    @State var addReviewSheet = false
    
    var body: some View {
        ZStack {
            Color("lavenderBlush")
                .edgesIgnoringSafeArea(.all)
            
            // VStack to hold ScrollView for all content but the Rate Venue button, which is locked at the bottom.
            VStack(spacing: 0) {
                // ScrollView to not mess up UI if restaurants' info differ in size/scope.
                 ScrollView(.vertical, showsIndicators: true) {
                VStack {
                    Image("venue")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width, height: 250)
                        .padding(.bottom, 20)
                    
                    VenueInformationView(pin: pin)
                    
                    Text("Reviews")
                        .foregroundColor(Color(.oldRose))
                        .font(.system(size: 20))
                        .padding(.top, 10)
                        .padding(.bottom, 5)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 20) {
                            ForEach($mapVM.pinReviews, id: \.text) { $review in
                                ReviewView(review: review)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 20)
                  }
                
                CustomButton(label: "Rate Venue", backgroundColor: "oldRose", width: 250) {
                    addReviewSheet = true
                }
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            mapVM.listenToPinReviews(pin: pin)
        }
        .sheet(isPresented: $addReviewSheet) {
            AddReviewView(pin: pin, mapViewRef: mapViewRef)
                .presentationDetents([.fraction(0.3), .large])
        }
    }
}

//#Preview {
//    VenueDetailView()
//}



struct VenueInformationView : View {
    let pin : Pin
    
    var body : some View {
        VStack{
            StarsView(rating : pin.averageRating)
            Text(pin.name)
                .foregroundColor(Color(.oldRose))
                .font(.custom("Beau Rivage", size: 40)) // Don't know how to add custom fonts, I'll fix later
            Text("\(pin.streetAddress)\(pin.streetNo)")
                .foregroundColor(Color(.oldRose))
                .fontDesign(.rounded)
            Text(pin.phoneNumber)
                .foregroundColor(Color(.oldRose))
                .fontDesign(.rounded)
            Text(pin.website)
                .foregroundColor(Color(.oldRose))
        }
    }
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

struct ReviewView : View {
    let review : ReviewData
    
    var body : some View {
        VStack(alignment: .leading){
            HStack {
                if review.userName == "" {
                    Text("Anonymous")
                        .font(.headline)
                        .padding(.top, 5)
                        .foregroundColor(Color(.raisinBlack))
                }
                else {
                    Text(review.userName)
                        .font(.headline)
                        .padding(.top, 5)
                        .foregroundColor(Color(.raisinBlack))
                }
             
                
                StarsView(rating: Double(review.rating))
            }
            .bold()
            .padding(.bottom, 7)
            
            Text(review.text)
                .font(.subheadline)
                .foregroundColor(.secondary)
               // .lineLimit(5) // If we want to limit how many rows that are displayed in review card.
               // .truncationMode(.tail) // To show ... if text is to long.
        }

        .padding(.leading, 20)
        .frame(width: UIScreen.main.bounds.width * 0.8, height: 150, alignment: .topLeading)
        .background(Color(.thistle))
        .cornerRadius(10)
    }
}




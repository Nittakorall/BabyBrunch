//
//  VenueDetailView.swift
//  BabyBrunch
//
//  Created by test2 on 2025-05-20.
//

import SwiftUI

struct VenueDetailView: View {
   
   let pin: Pin
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
                  
                  ScrollView(.horizontal) {
                     LazyHStack(spacing: 7) {
                        ForEach($mapVM.pinReviews, id: \.text) { $review in
                           ReviewView(review: review)
                        }
                     }
                  }
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
         AddReviewView(pin: pin)
            .presentationDetents([.fraction(0.3), .fraction(0.6), .large])
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
      ScrollView(.vertical) {
         VStack {
            HStack {
               Text("Review's rating: ")
                  .foregroundColor(Color(.lavenderBlush))
               StarsView(rating: Double(review.rating))
            }
            .bold()
            .padding(.bottom, 7)
            .frame(maxWidth: .infinity, alignment: .center)
            
            Text(review.text)
               .fixedSize(horizontal: false, vertical: true)
               .font(.system(size: 12))
               .foregroundColor(Color(.lavenderBlush))
            //               .lineLimit(5) // If we want to limit how many rows that are displayed in review card.
            //               .truncationMode(.tail) // To show ... if text is to long.
         }
         .frame(maxWidth: .infinity, alignment: .topLeading)
         .padding()
         .background(Color(.thistle))
         .cornerRadius(30)
         .padding(.leading, 30)
      }
      .frame(width: 370, height: 280)
      .clipped()
   }
}



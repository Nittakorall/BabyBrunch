//
//  UserReviewsView.swift
//  BabyBrunch
//
//  Created by KiwiComp on 2025-06-05.
//

import SwiftUI
import MapKit

struct UserReviewsView: View {
    @State var userReviewList : [ReviewData] = []
    @StateObject var mapVM = MapViewModel()
    @Binding var mapViewRef : MKMapView?
    
    var body: some View {
        ZStack {
            Color(.lavenderBlush)
                .ignoresSafeArea()
            VStack {
                Text( "Your reviews")
                    .padding(.top, 50)
                    .fontDesign(.rounded)
                    .font(.title)
                    .foregroundColor(Color(.oldRose))
                Text("(Swipe a review to delete it.)")
                    .font(.system(size: 10))
                    .foregroundColor(Color(.oldRose))
                List {
                    ForEach(userReviewList, id: \.pinName) { review in
                        UserReviews(review: review)
                    }
                    .onDelete(perform: deleteReview)
                    .listRowBackground(Color(.lavenderBlush))
                }
                .scrollContentBackground(.hidden)
            }
        }
        .onAppear {
            mapVM.fetchReviewsByCurrentUser { list in
                userReviewList = list
            }
        }
    }
    
    func deleteReview(at indexSet: IndexSet) {
        // Iterate over each index in the IndexSet sent into the function.
        for index in indexSet {
            let reviewToDelete = userReviewList[index]
            
            // Call function to deleteReview in mapVM. If returning bool is true, execute more code.
            mapVM.deleteReview(pinId: reviewToDelete.pinId ?? "") { success in
                if success {
                    // Call function to removeRating in mapVM, which has a callback with three variabels: if success is true, use the fetched pin to remove and create annotation for that pin with the new average.
                    mapVM.removeRating(from: reviewToDelete.pinId ?? "", ratingToRemove: reviewToDelete.rating) { success, newAverage, fetchedPin in
                        if success {
                            if let mapView = mapViewRef, let newAverage = newAverage, let pin = fetchedPin {
                                // Call function to updateAnnotation on map to display new average for the pin.
                                mapVM.updateAnnoatation(mapView: mapView, pin: pin, newAverage: newAverage)
                            }
                            // On the main thread, remove the review to delete from the local list.
                            DispatchQueue.main.async {
                                userReviewList.remove(atOffsets: indexSet)
                            }
                        }
                    }
                }
            }
        }
    }
    
}

//#Preview {
//    UserReviewsView()
//}

struct UserReviews : View {
    let review : ReviewData
    
    var body : some View {
        VStack(alignment: .leading){
            HStack {
                Text("For venue: ")
                    .bold()
                Text(review.pinName ?? "errorPinName")
            }
            .padding(.top, 5)
            .foregroundColor(Color(.raisinBlack))
            .font(.system(size: 14))
            
            HStack {
                Text("Your rating: ")
                StarsView(rating: Double(review.rating))
            }
            .bold()
            .font(.system(size: 12))
            .foregroundColor(Color(.raisinBlack))
            .padding(.bottom, 7)
            
            Text(review.text)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .padding(.leading, 20)
        .padding(.trailing, 20)
        .frame(width: UIScreen.main.bounds.width * 0.8, height: 150, alignment: .topLeading)
        .background(Color(.thistle))
        .cornerRadius(10)
    }
}

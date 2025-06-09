//
//  AddReviewView.swift
//  BabyBrunch
//
//  Created by test2 on 2025-05-25.
//

import SwiftUI
import MapKit
import AVFoundation
import ConfettiSwiftUI

struct AddReviewView: View {
    @State private var reviewText = ""
    @State private var userName = ""
    @State var rating = 0
    @State private var viewHeight: CGFloat = 0
    @ObservedObject var soundVM = SoundViewModel()
    // Brings our pin from detailView
    @Binding var pin: Pin
    let mapViewRef: MKMapView?
    private let mapVM = MapViewModel()
    @Environment(\.dismiss) var dismiss
    @State var showAlert : ReviewAlerts?
    
    //confetti trigger
    // ───────────────────────────────────────────
    @State private var confetti: Int = 0
    @State private var deletionInFlight = false
    // ───────────────────────────────────────────
    
    var body: some View {
        ZStack {
            Color("lavenderBlush")
                .edgesIgnoringSafeArea(.all)
            
            GeometryReader { geo in
                VStack {
                    if viewHeight < 400 {
                        Text("Pull to open")
                            .foregroundColor(Color(.oldRose))
                            .padding(.top, 7)
                    }
                    
                    CustomTitle(title: "Choose a star rating:")
                    //-15 padding so that title doesn't take all space in 0.3
                        .padding(.vertical, -20)
                    
                    
                    StarRatingView(rating: $rating, vm : soundVM)
                        .padding(.bottom, 10)
                    //if fraction of the view is more than 0.3, review field will be shown
                    
                    
                    if viewHeight > 300 {
                        //add review field
                        VStack{
                            CustomTitle(title : "Add your review:")
                            
                            
                            Text("What's your name?")
                                .foregroundColor(Color(.oldRose))
                            TextEditor(text: $userName)
                                .frame(height: 50)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(.thistle), lineWidth: 2)
                                )
                                .padding(.horizontal, 20)
                            
                            TextEditor(text: $reviewText)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(.thistle), lineWidth: 2)
                                )
                                .padding(.horizontal, 20)
                            
                        }
                        //0.6 and 1 fraction is for some reason not centered without it
                        // .frame(maxWidth: .infinity, alignment: .center)
                    }
                    
                    //button "add review"
                    CustomButton(label: "Add review", backgroundColor: "oldRose", width: 350) {
                        guard !deletionInFlight else { return }    // already running
                        deletionInFlight = true
                        if rating == 0 {
                            print("Rating is 0, i.e. no star chosen.")
                            showAlert = .noRating
                            deletionInFlight = false
                        } else {
                            // Nil check mapViewRef.
                            if let mapView = mapViewRef {
                                mapVM.addRating(to: pin, rating: rating, review: reviewText, userName: userName) { success, newAverage in
                                    if success, let newAverage = newAverage {
                                        //add rating to local-list to show new average directly in detailview
                                        pin.ratings.append(rating)
                                        confetti += 1                              // 🎉 launch confetti
                                        // Keep the sheet open long enough for the confetti animation, then dismiss.
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                            deletionInFlight = false
                                            dismiss()
                                        }
                                        soundVM.playSound(resourceName: "AddReviewSound", resourceFormat: "wav")
                                        print("newAverage inside if let success, let newAverage: \(newAverage)")
                                        print("Added rating: \(rating)")
                                        
                                        // Call function to update pin average rating on map.
                                        mapVM.updateAnnoatation(mapView: mapView, pin: pin, newAverage: newAverage)
                                    }
                                } reviewExists: { exists in
                                    if exists {
                                        deletionInFlight = false
                                        showAlert = .alreadyReviewed
                                    }
                                }
                            }
                        }
                    }
                    .disabled(deletionInFlight)                // prevent double‑taps
                    .confettiCannon(trigger: $confetti, confettis: [.text("⭐"), .text("⭐"), .text("👶"),.text("⭐"),.text("⭐")], confettiSize: 20)       // 🎉
                    .padding(.bottom, 30)
                    .padding(.top, 5)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                
                .frame(maxHeight: .infinity, alignment: .top)
                .onAppear {
                    viewHeight = geo.size.height
                }
                //updates the view if fraction size changes
                .onChange(of: geo.size.height) { newValue in
                    viewHeight = newValue
                    
                }
                .alert(item: $showAlert) { reviewAlert in
                    switch reviewAlert {
                    case .noRating:
                        return Alert(
                            title: Text("No rating"),
                            message: Text("Please choose a star for your rating."),
                            dismissButton: .cancel(Text("OK")))
                    case .alreadyReviewed:
                        return Alert(
                            title: Text("You have already left a review for this venue."),
                            dismissButton: .cancel(Text("OK")))
                    }
                }
            }
        }
    }
    
    struct StarRatingView: View {
        @Binding var rating: Int
        @ObservedObject var vm : SoundViewModel
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
                            // @ObservedObject var soundVM = SoundViewModel(resourceName: "StarSound", resourceFormat: "wav")
                            vm.playSound(resourceName: "StarSound", resourceFormat: "wav")
                            rating = index
                            print("Rating: \(rating)")
                        }
                }
            }
        }
    }
}

enum ReviewAlerts : Identifiable {
    case noRating, alreadyReviewed
    
    var id: Int {
        switch self {
        case .noRating: return 0
        case .alreadyReviewed: return 1
        }
    }
}

//#Preview {
//    AddReviewView()
//}

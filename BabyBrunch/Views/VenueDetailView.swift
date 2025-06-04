//
//  VenueDetailView.swift
//  BabyBrunch
//
//  Created by test2 on 2025-05-20.
//

import SwiftUI
import MapKit

struct VenueDetailView: View {
    
    @State var pin: Pin
    let mapViewRef: MKMapView?
    @StateObject var mapVM = MapViewModel()
    @EnvironmentObject private var authVM: AuthViewModel
    
    @State var addReviewSheet = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    var onDismiss: (() -> Void)? = nil
    
    @State private var showUrlAlert = false
    @State private var url: URL?
    
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
                    if !authVM.isSignedUp {
                        authVM.authError = .guestNotAllowed
                    } else {
                        addReviewSheet = true
                    }
                }
                .padding(.bottom, 20)
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button {
                        //calls the toggle favorite function 
                        if let pinId = pin.id {
                            authVM.toggleFavorite(pinId: pinId) { success in
                                print(success ? "Toggled favorite" : "Failed")
                            }
                        }
                    } label: {
                        //Shows button as a filled in or outlined heart depending on if the pin is marked favorite or not
                        Image(systemName: authVM.currentUser?.favorites.contains(pin.id ?? "") == true ? "heart.fill" : "heart")
                            .foregroundStyle(.red)
                            .padding()
                            .font(.title)
                    }
                }
                Spacer()
            }
            
        }
        .onAppear {
            //Takes current selected pinId and fetch the new data from that pin on firestore to get a correct average rating
            if let id = pin.id {
                mapVM.fetchPin(withId: id) { updatedPin in
                    if let updatedPin = updatedPin {
                        self.pin = updatedPin
                    }
                }
            }
            mapVM.listenToPinReviews(pin: pin)
        }
        .sheet(isPresented: $addReviewSheet) {
            AddReviewView(pin: $pin, mapViewRef: mapViewRef)
                .presentationDetents([.fraction(0.3), .large])
        }
        // Show guest alert when authError changes
        .onChange(of: authVM.authError) { newError in
            if let error = newError {
                alertMessage = error.localizedDescription
                showAlert = true
            }
        }
        .onDisappear {
            onDismiss?()
        }
        .alert("Guest Access Denied",
               isPresented: $showAlert,
               actions: {
                   Button("OK") {
                       authVM.authError = nil   // reset so alert can show next time
                   }
               },
               message: { Text(alertMessage) })
    }
}

//#Preview {
//    VenueDetailView()
//}



struct VenueInformationView : View {
    let pin : Pin
    
    var body : some View {
        VStack{
            StarsDynamicFillView(rating : pin.averageRating)
            Text(pin.name)
                .foregroundColor(Color(.oldRose))
                .font(.custom("Beau Rivage", size: 40)) // Don't know how to add custom fonts, I'll fix later
            Text("\(pin.streetAddress)\(pin.streetNo)")
                .foregroundColor(Color(.oldRose))
                .fontDesign(.rounded)
            Text(pin.phoneNumber)
                .foregroundColor(Color(.oldRose))
                .fontDesign(.rounded)
            LinkView(pin: pin)
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
                    Text(review.userName ?? "Anonymous")
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

struct LinkView : View {
    let pin : Pin
    @State var showUrlAlert = false
    
    
    var body : some View {
        if let url = URL(string: pin.website) {
            Button {
                showUrlAlert = true
            } label: {
                Text(pin.website)
                    .foregroundColor(Color(.oldRose))
                    .underline()
            }
            .alert("Do you want to open this link?", isPresented: $showUrlAlert) {
                Button("Yes") {
                    UIApplication.shared.open(url)
                }
                Button("No", role: .cancel) {}
            }
        } else {
            Text(pin.website)
                .foregroundColor(Color(.oldRose))
        }
    }
}


struct StarsDynamicFillView: View {
    var rating: Double
    private let maxRating = 5 // How many stars are rated/displayed.
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<maxRating, id: \.self) { index in
                starView(for: index) // Generate view for each star. WHY FUNCTION AND NOT JUST VIEW?
                    .frame(width: 24, height: 24) // Size of each star.
            }
        }
    }
    
    private func starView(for index: Int) -> some View {
        // Calculate fill level for star, use the rating (2,3) and for each star subtract the index of the star.
        // Since fillevel can be more than 1 and less than 0, it's limited to 0.0 and 1.0.
        // If rating is 2,3, then stars 1 and 2 will have fill level 1.0 -> 100% filled. The 3rd star will be at 0,3 -> 30% filled. 4th and 5th star at 0 -> 0% filled.
        let fillLevel = max(0.0, min(1.0, rating - Double(index)))
        
        // ZStack to have different layers depending on fill level.
        return ZStack {
            // Empty gray star.
            Image(systemName: "star")
                .resizable() // To fit inside frame.
                .scaledToFit() // To fit inside frame.
                .foregroundColor(.gray)
            
            // To fill the star according to its fill level, only if fill level is larger than 0.
            if fillLevel > 0 {
                // Fylld stjärna, men bara till den procent som behövs
                Image(systemName: "star.fill")
                    .resizable() // To fit inside frame.
                    .scaledToFit() // To fit inside frame.
                    .foregroundStyle(LinearGradient(colors: [Color(.lightYellowStar), Color(.darkYellowStar)], startPoint: .top, endPoint: .bottom)) // Gradient colour (instead of just plain colour).
                    .shadow(color: .black.opacity(0.3), radius: 1, x: -1, y: 1) // Shadow for 3D effect.
                
                // To only reveal colour according to fillevel.
                    .mask(
                        // Get the size of the star and paint a rectangle on top of it.
                        // Mask only colours the portion of the rectangle above the star, not the negative space around the star.
                        GeometryReader { geometry in
                            Rectangle()
                                .size(width: geometry.size.width * fillLevel,
                                      height: geometry.size.height)
                        }
                    )
            }
        }
    }
}




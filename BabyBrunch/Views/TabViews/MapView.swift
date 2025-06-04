//
//  MapView.swift
//  BabyBrunch
//
//  Created by KiwiComp on 2025-05-19.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @Binding var mapViewRef: MKMapView?
    @State private var selectedVenue : MKMapItem? = nil
    
    let mapVM = MapViewModel()
    
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showSheet = false
    
    @State private var selectedPin: Pin? = nil
    @State private var showPinSheet = false
    
    @StateObject private var vm = LocationViewModel()
    @StateObject private var searchLocationVM = SearchLocationViewModel()
    @State var searchLocation = ""
    
    var body : some View {
        ZStack{
            UIKitMapView(
                showAlert: $showAlert,
                alertTitle: $alertTitle,
                alertMessage: $alertMessage,
                mapViewRef: $mapViewRef,
                selectedVenue: $selectedVenue,
                vm : vm,
                region: $vm.realRegion,
                selectedPin: $selectedPin,
                searchLocationVM: searchLocationVM)
            .ignoresSafeArea()
            .accentColor(Color(.thistle))
            
            //checks if user needs to give permission
            .onAppear() {
                vm.checkIfLocationServicesEnabled()
            }
            
            //listens for authvmerrors
            .onChange(of: authVM.authError) { newError in
                if let error = newError {
                    alertTitle = "Guest Access Denied"
                    alertMessage = error.localizedDescription
                    showAlert = true
                }
            }
            .alert(isPresented: $showAlert) {
                if alertTitle == "Guest Access Denied" {
                    return Alert(
                        title: Text(alertTitle),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("OK"),
                        action: {
                            // clears the error to make the map clickable agin
                            authVM.authError = nil
                                                })
                    )
                    
                } else {
                    return Alert(
                        title: Text(alertTitle),
                        message: Text(alertMessage),
                        primaryButton: .default(Text("Yes"),
                        action: {
                            savePOItoPin()
                        }),
                        secondaryButton: .cancel(Text("Cancel"))
                    )
                }
            }
                            
            
            //opens a sheet of venuedetails and sends the clickable pin along
            .sheet(item: $selectedPin) { pin in
               VenueDetailView(pin: pin, mapViewRef: mapViewRef)
                }
            VStack {
                CustomButton(label: "Where am I?", backgroundColor: "oldRose", width: 150) {
                    vm.mapShouldBeUpdated = true
                    vm.checkIfLocationServicesEnabled()
                }.padding(.bottom, 10)
                HStack {
                    CustomTextField(input: $searchLocation, hint: "Type city", type: .normal)
                        .padding(.leading, 30)
                    Button(action: {
                        if searchLocation.isEmpty {
                            print("Search term is empty.")
                            //                        showEmptySearchAlert = true
                        } else {
                            Task {
                                await searchLocationVM.fetchCoordinates(for: searchLocation)
                                vm.mapShouldBeUpdated = false
                            }
                        }
                    }){
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(Color(.oldRose))
                    }
                    .padding(.trailing, 20)
                    .padding(.leading, 5)
                }
                Spacer()
            }
        }
    }
    
    // MARK: Functions
    
    /*
     * If selectedVenue and mapViewRef are not nil:
     * Take out the data we want for the Pin from MKMapItem (selectedVenue)
     * Create a new Pin.
     * Call function from mapVM to save pin to Firestore.
     * If successful, call function to create an annotation to be places on the mapView.
     */
    func savePOItoPin () {
        guard authVM.currentUser?.isSignedUp == true else {
            authVM.authError = .guestNotAllowed //triggers the alert string found in AuthErrorHandler
            return
        }
        if let venue = selectedVenue, let _ = mapViewRef {
            if let name = venue.placemark.name,
               let streetAddress = venue.placemark.thoroughfare,
               let streetNo = venue.placemark.subThoroughfare,
               let website = venue.url?.absoluteString,
               let phoneNumber = venue.phoneNumber {
                let latitude = venue.placemark.coordinate.latitude
                let longitude = venue.placemark.coordinate.longitude
                
                let newPin = Pin(
                    name: name,
                    streetAddress: streetAddress,
                    streetNo: streetNo,
                    website: website,
                    phoneNumber: phoneNumber,
                    latitude: latitude,
                    longitude: longitude
                )
                print(newPin)
                mapVM.savePinToFirestore(pin: newPin) { savedPin in
                    if let updatedPin = savedPin {
                        //creates the new pin with the id from firestore
                        createAnnotationForMapView(pin: updatedPin)
                    }
                }
            }
        }
    }
    
    /*
     * Takes in the newly created pin in the function savePOItoPin in this file.
     * Use the data from the pin to create an annotation.
     * Add the annotation to the mapView.
     */
    func createAnnotationForMapView(pin: Pin) {
        if let _ = selectedVenue, let mapView = mapViewRef {
            let annotation = PinAnnotation()
            annotation.pin = pin
            annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
            annotation.title = pin.name
            annotation.subtitle = String(format: "⭐️: %.1f", pin.averageRating)
            
            mapView.addAnnotation(annotation)
        }
    }
}


//#Preview {
//    MapView()
//}

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
    @State private var mapViewRef: MKMapView? = nil
    @State private var selectedVenue : MKMapItem? = nil
    let mapVM = MapViewModel()
    
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showSheet = false
    
    @State private var selectedPin: Pin? = nil
    @State private var showPinSheet = false
    
    @StateObject private var vm = LocationViewModel()
    
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
                selectedPin: $selectedPin)
            .ignoresSafeArea()
            .accentColor(Color(.thistle))
            
            //checks if user needs to give permission
            .onAppear() {
                vm.checkIfLocationServicesEnabled()
            }
            //öppnar en sheet av venuedetails och skickar med den klickade pinnen
            .sheet(item: $selectedPin) { pin in
                    VenueDetailView(pin: pin)
                }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    primaryButton: .default(Text("Yes"), action: {
                        savePOItoPin()
                    }),
                    secondaryButton: .cancel(Text("Cancel"))
                )
            }
            Button("Where am I?") {
                vm.mapShouldBeUpdated = true
                vm.checkIfLocationServicesEnabled()
            }
            
            .foregroundColor(.white)
            .frame(width: 150, height: 10)
            .padding()
            .background(Color("oldRose"))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black, lineWidth: 1)
            )
            .padding(.bottom, 600)
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
                mapVM.savePinToFirestore(pin: newPin) { success in
                    if success {
                        createAnnotationForMapView(pin: newPin)
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
            let annotation = MKPointAnnotation()
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

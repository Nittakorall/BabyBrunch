//
//  UIKitMapView.swift
//  BabyBrunch
//
//  Created by KiwiComp on 2025-05-19.
//

import SwiftUI
import MapKit

struct UIKitMapView : UIViewRepresentable {
    
    @Binding var showAlert: Bool
    @Binding var alertTitle : String
    @Binding var alertMessage: String
    @Binding var mapViewRef: MKMapView?
    @Binding var selectedVenue : MKMapItem?
    @EnvironmentObject var authVM: AuthViewModel // for error handling
    let mapViewModel = MapViewModel()
    @ObservedObject var vm : LocationViewModel
    //used for user location
    @Binding var region: MKCoordinateRegion
    
    @Binding var selectedPin: Pin?
    @ObservedObject var searchLocationVM: SearchLocationViewModel
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            parent: self,
            showAlert: $showAlert,
            alertTitle: $alertTitle,
            alertMessage: $alertMessage,
            selectedVenue: $selectedVenue,
            selectedPin: $selectedPin,
            authVM: authVM)
    }
    
    func makeUIView(context: Context) -> MKMapView { // This is required for UIKitMapView to fulfill the requirements of the UIViewRepresentable protocol.
        /*
         ✅ Creates a map.
         ✅ Sets a delegate so you can control and listen for interactions.
         ✅ Shows the user's location.
         ✅ Displays points of interest like stores and restaurants directly on the map.
         */
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
//       mapView.pointOfInterestFilter = .includingAll // Shows all Points of Interest (POIs) on the map.
        mapView.pointOfInterestFilter = MKPointOfInterestFilter(including: [.restaurant, .cafe]) // Shows only POIs that are restaurants or cafés.
        mapViewRef = mapView
        
        /*
         ✅ Creates a tap recognizer on the map.
         ✅ Requires only one tap with one finger.
         ✅ Does not block the map’s built-in interactions.
         ✅ Connects to the Coordinator for logic and handling.
         ✅ Adds it to the MKMapView.
         */
        let tapRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:))) // Creates a new UITapGestureRecognizer – a UIKit object that reacts to tap gestures on the screen. It will call the handleTap(_:) function in your Coordinator class when a tap is detected. target: The object whose method should be called – here it is context.coordinator, your Coordinator instance (a bridge between SwiftUI and UIKit). action: The method to call when the tap occurs. #selector(Coordinator.handleTap(_:)) refers to an Objective-C compatible method in your Coordinator.
        tapRecognizer.numberOfTapsRequired = 1 // Specifies that one tap is enough for the gesture to be recognized. This is the default value but is often explicitly stated for clarity.
        tapRecognizer.numberOfTouchesRequired = 1 // Specifies that only one finger touch is required. If you set this to 2, the gesture would only be recognized when two fingers tap simultaneously.
        tapRecognizer.cancelsTouchesInView = false // Determines whether this gesture recognizer prevents other touch events from reaching underlying views. Set to false means other interactions (e.g., scrolling or zooming on the map) are not blocked by the tap recognizer.
        tapRecognizer.delegate = context.coordinator // Sets the Coordinator as the delegate for the gesture recognizer.
        mapView.addGestureRecognizer(tapRecognizer) // Adds the tap recognizer to the mapView so it listens for user taps.
        
        /*
         ✅ Creates a region (centered on Uppsala).
         ✅ Defines the zoom level via span.
         ✅ Sets the map to display that area.
         ✅ Returns the map so it can be shown in your SwiftUI layout.
         */
        
        
        
        //We don't need region variable here because we get location data from locationVM, replaced region it with vm.realRegion
        
        let defaultRegion = MKCoordinateRegion( // You create a new MKCoordinateRegion object. It's used by MKMapView to define which area to show.
            // center: CLLocationCoordinate2D(latitude: 59.8609, longitude: 17.6486), // Uppsala
            center: CLLocationCoordinate2D(latitude: 59.325, longitude: 18.05), // Stockholm
            //         center: CLLocationCoordinate2D(latitude: 57.706, longitude: 11.954), // Göteborg
            //         center: CLLocationCoordinate2D(latitude: 56.04673, longitude: 12.69437), // Helsingborg
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
        mapView.setRegion(defaultRegion, animated: false) // You instruct MKMapView to display the exact region you just created. setRegion(_:animated:) is a method that updates the visible area of the map. animated: false means the map jumps directly to the region without any animation (no zooming or panning). If you set animated: true, the map will animate itself to the new location, which can be a nicer experience for the user.
        
        mapViewModel.fetchAllPins { success in
            if success {
                for annotation in mapView.annotations{
                    mapView.removeAnnotation(annotation)
                }
                DispatchQueue.main.async {
                    for annotation in mapViewModel.venuePins.values {
                        mapView.addAnnotation(annotation)
                    }
                }
            } else {
                print("Could not add annotations from Firestore to mapView in UIKitMapView.")
            }
        }
        
        return mapView // You return the newly configured MKMapView object from makeUIView(context:) in UIViewRepresentable. This map will be shown in your SwiftUI view.
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        if vm.mapShouldBeUpdated {
            // Updates the map if the user's location changes
            uiView.setRegion(vm.realRegion, animated: false)
        } // This is required for UIKitMapView to fulfill the requirements of the UIViewRepresentable protocol.
        
        
        if let coordinates = searchLocationVM.coordinates {
            let newRegion = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: coordinates.lat, longitude: coordinates.lon),
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            )
            uiView.setRegion(newRegion, animated: true)
            DispatchQueue.main.async {
                searchLocationVM.coordinates = nil
            }
            
        }
    }
}


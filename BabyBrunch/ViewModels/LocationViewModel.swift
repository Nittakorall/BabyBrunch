//
//  LocationViewModel.swift
//  BabyBrunch
//
//  Created by test2 on 2025-05-20.
//

import Foundation
import MapKit
import CoreLocation
import SwiftUI

class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var realRegion: MKCoordinateRegion
    var locationManager: CLLocationManager?
    
    //we override init of NSObject
    override init() {
        //region that shows if users locations is not available, Stockholm
        self.realRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 59.3293, longitude: 18.0686),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        
        super.init()
        checkIfLocationServicesEnabled()
    }
    
    
    
    //function that checks if location services are enabled on the phone
    func checkIfLocationServicesEnabled() {
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            // we can add it if we need it later, it's use to choose how precicely we'll show users location
            //    locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            
            locationManager!.delegate = self
            
        } else {
            //    showAlert = true
            //TODO: would be better with an alert here so that user turns on location
            
        }
        // print( "Location services are not enabled." )
    }
    
    
    func checkLocationAuthorization() {
        guard let locationManager = locationManager else { return }
        
        switch locationManager.authorizationStatus {
            //shows if we never asked before
        case .notDetermined:
            //   showAlert = true
            locationManager.requestWhenInUseAuthorization()
            
            
        case .restricted:
            //     showAlert = true
            print("Restricted location")
            locationManager.requestWhenInUseAuthorization()
            
        case .denied:
            //    showAlert = true
            print("Denied location")
            locationManager.requestWhenInUseAuthorization()
            
            //if we're already shared the location, it will change region to our location
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            //idk how to get here and how to cause default in this case, so I just break
        @unknown default:
            break
        }
    }
    
    //function that updates the map if users location is changed
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    //function that follows anf updates the map based om where the user is
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else { return }
        
        DispatchQueue.main.async {
            self.realRegion = MKCoordinateRegion(
                center: latestLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            )
            self.locationManager?.stopUpdatingLocation()
        }
    }
}


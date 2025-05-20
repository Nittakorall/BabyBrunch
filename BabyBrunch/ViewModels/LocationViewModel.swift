//
//  LocationViewModel.swift
//  BabyBrunch
//
//  Created by test2 on 2025-05-20.
//

import Foundation
import MapKit
import CoreLocation

 class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    var locationManager : CLLocationManager?
    
    func checkIfLocationServicesEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            //    locationManager?.desiredAccuracy = kCLLocationAccuracyBest // add if you need it later
                // checkLocationAuthorization( ) // redundant
            locationManager!.delegate = self
            
        } else {
            print( "Location services are not enabled." )
        }
        
    }
    func checkLocationAuthorization() {
        guard let locationManager = locationManager else { return }
      
        switch locationManager.authorizationStatus {
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization( )
        case .restricted:
            print("Restricted location")
        case .denied:
            print("You denied location")
        case .authorizedAlways, .authorizedWhenInUse:
            break
        @unknown default:
        break
        }
    }
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}


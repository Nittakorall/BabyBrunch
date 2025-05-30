//
//  PinAnnotation.swift
//  BabyBrunch
//
//  Created by Victor Sundberg on 2025-05-22.
//

import Foundation
import MapKit

class PinAnnotation: MKPointAnnotation {
    var pin: Pin?

   // Default init, we can create an empty pin when user adds a new pin to the map.
   override init() {
       super.init()
   }

   // Custom init that takes in an existing pin when we create a new pin, i.e. ee create a new pin based on an existing one.
   // We can easily update a pin on the map with new info (e.g. averageRating).
    init(pin: Pin) {
        super.init()
        self.pin = pin
        self.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        self.title = pin.name
        self.subtitle = String(format: "⭐️: %.1f", pin.averageRating)
    }
    
}

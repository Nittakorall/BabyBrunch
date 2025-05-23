//
//  MapViewModel.swift
//  BabyBrunch
//
//  Created by KiwiComp on 2025-05-20.
//

import Foundation
import Firebase
import MapKit

class MapViewModel : ObservableObject {
   @Published var venuePins : [String: MKPointAnnotation] = [:]
   let db = Firestore.firestore()
   
   /*
    * Creates query to check if a doc in pin-collection exists with equal name, latitude and longitude.
    * If no, create a new pin.
    * If yes, do nothing.
    */
   func savePinToFirestore(pin: Pin, completion: @escaping (Bool) -> Void) {
      let ref = db.collection("pins")
      let query = ref
         .whereField("name", isEqualTo: pin.name)
         .whereField("latitude", isEqualTo: pin.latitude)
         .whereField("longitude", isEqualTo: pin.longitude)
      
      query.getDocuments { snap, err in
         if let error = err {
            print("Error getting pin documents: \(error.localizedDescription) (In file: \((#file as NSString).lastPathComponent), on line: \(#line))")
            completion(false)
         } else {
            if snap!.isEmpty {
               do {
                  try ref.addDocument(from: pin)
                  print("This pin is new, saved pin to Firestore. (In file: \((#file as NSString).lastPathComponent), on line: \(#line))")
                  completion(true)
               } catch {
                  print("Failed to save new pin to Firestore: \(error.localizedDescription) (In file: \((#file as NSString).lastPathComponent), on line: \(#line))")
                  completion(false)
               }
            } else {
               print("This pin already exists on Firestore. (In file: \((#file as NSString).lastPathComponent), on line: \(#line))")
               completion(false)
            }
         }
      }
   }
   
   /*
    * Fetch all pins from pin collection on Firestore.
    * For each pin-document in the snapshot, parse it to our Pin-object.
    * For each also create an annotation to store in venuePins. 
    * Callback returns true also if the snapshot is empty (no pins have been created yet).
    * Function is called in UIKitMapView when the mapView is created.
    * The callback (when true) loops over venuePins and adds each annotation to the mapView to be displayed on the map. 
    */
   func fetchAllPins(completion: @escaping (Bool) -> Void) {
      let ref = db.collection("pins")
      
      ref.getDocuments { snap, err in
         if let error = err {
            print("Failed to get fetch all pins from Firestore: \(error.localizedDescription) (In file: \((#file as NSString).lastPathComponent), on line: \(#line))")
            completion(false)
         }
         guard let snapshot = snap else {
            print("No snapshot returned.")
            completion(false)
            return
         }
         if snapshot.isEmpty {
            print("No snap documents exist, venuePins is npw empty. (In file: \((#file as NSString).lastPathComponent), on line: \(#line))")
            completion(true)
            return
         }
         
         for doc in snapshot.documents {
            do {
               let pin = try doc.data(as: Pin.self)
               if let id = pin.id {
                  let annotation = MKPointAnnotation()
                  annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                  annotation.title = pin.name
                  annotation.subtitle = String(format: "⭐️: %.1f", pin.averageRating)
                  self.venuePins[id] = annotation
               }
            } catch {
               print("Could not parse Firestore pin: \(error.localizedDescription) (In file: \((#file as NSString).lastPathComponent), on line: \(#line))")
               continue
            }
         }
         completion(true)
      }
   }
   
   func fetchClickedPin(pinId : String, completion: @escaping (Pin?) -> Void) {
      let ref = db.collection("pins").document(pinId)
      
      ref.getDocument { snap, err in
         if let error = err {
            print("Error fetching pin document from Firestore: \(error.localizedDescription) (In file: \((#file as NSString).lastPathComponent), on line: \(#line))")
            completion(nil)
            return
         }
         
         guard let document = snap else {
            print("Pin document does not exist. (In file: \((#file as NSString).lastPathComponent), on line: \(#line))")
            completion(nil)
            return
         }
         
         do {
            let pin = try document.data(as: Pin.self)
            print("Successfully parsed pin from Firestore. (In file: \((#file as NSString).lastPathComponent), on line: \(#line))")
            completion(pin)
         } catch {
            print("Could not parse pin: \(error.localizedDescription) (In file: \((#file as NSString).lastPathComponent), on line: \(#line))")
            completion(nil)
         }
      }
   }
   
   
}

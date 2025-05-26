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
       if Auth.auth().currentUser?.isAnonymous == true {
               print("Guest cannot create pins.")
               completion(false)   // No alert here
               return
           }
      let ref = db.collection("pins")
      let query = ref
         .whereField("name", isEqualTo: pin.name)
         .whereField("latitude", isEqualTo: pin.latitude)
         .whereField("longitude", isEqualTo: pin.longitude)
      
      query.getDocuments { snap, err in
         if let error = err {
            print("Error getting pin documents: \(error.localizedDescription)")
            completion(false)
         } else {
            if snap!.isEmpty {
               do {
                  try ref.addDocument(from: pin)
                  print("This pin is new, saved pin to Firestore.")
                  completion(true)
               } catch {
                  print("Failed to save new pin to Firestore: \(error.localizedDescription)")
                  completion(false)
               }
            } else {
               print("This pin already exists on Firestore.")
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
            print("Failed to get fetch all pins from Firestore: \(error.localizedDescription)")
            completion(false)
         }
         guard let snapshot = snap else {
            print("No snapshot returned.")
            completion(false)
            return
         }
         if snapshot.isEmpty {
            print("No snap documents exist, venuePins is now empty.")
            completion(true)
            return
         }
         
         for doc in snapshot.documents {
            do {
               let pin = try doc.data(as: Pin.self)
               if let id = pin.id {
                   let annotation = PinAnnotation()
                   annotation.pin = pin
                  annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                  annotation.title = pin.name
                  annotation.subtitle = String(format: "⭐️: %.1f", pin.averageRating)
                  self.venuePins[id] = annotation
               }
            } catch {
               print("Could not parse Firestore pin: \(error.localizedDescription)")
               continue
            }
         }
         completion(true)
      }
   }
    
    //Funktion för att kunna lägga till en rating på en pin till firestore
    //Tar in den pin som ska läggas till i och den rating som ska läggas till
    func addRating(to pin: Pin, rating: Int, completion: @escaping (Bool) -> Void) {
        guard let pinId = pin.id else {
            print("No pin id")
            completion(false)
            return
        }
        
        //Hämtar hela pin dokumentet
        let ref = db.collection("pins").document(pinId)
        
        ref.getDocument { snapshot, error in
            if let error = error {
                print("Error getting pin: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            //Ur dokumentet hämtas ratings arrayen
            guard let data = snapshot?.data(),
                  var existingRatings = data["ratings"] as? [Int] else {
                print("Failed reading array")
                completion(false)
                return
            }
            
            //lägger till ratingen i arrayen som hämtats
            existingRatings.append(rating)
            
            //uppdaterar firestore med den nya uppdaterade arrayeb
            ref.updateData(["ratings": existingRatings]) { error in
                if let error = error {
                    print("Failed to update: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("Rating added!")
                    completion(true)
                }
            }
        }
        
        
    }
   
   
}

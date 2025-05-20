//
//  MapViewModel.swift
//  BabyBrunch
//
//  Created by KiwiComp on 2025-05-20.
//

import Foundation
import Firebase

class MapViewModel : ObservableObject {
   
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
   
}

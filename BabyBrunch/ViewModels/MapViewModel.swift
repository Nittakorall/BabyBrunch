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
   @Published var pinReviews : [ReviewData] = []
   let db = Firestore.firestore()
   
   /*
    * Creates query to check if a doc in pin-collection exists with equal name, latitude and longitude.
    * If no, create a new pin.
    * If yes, do nothing.
    */
   func savePinToFirestore(pin: Pin, completion: @escaping (Pin?) -> Void) {
      let ref = db.collection("pins")
      let query = ref
         .whereField("name", isEqualTo: pin.name)
         .whereField("latitude", isEqualTo: pin.latitude)
         .whereField("longitude", isEqualTo: pin.longitude)
      
      query.getDocuments { snap, err in
         if let error = err {
            print("Error getting pin documents: \(error.localizedDescription)")
            completion(nil)
         } else {
            if snap!.isEmpty {
               do {
                   
                   //Adds document to firestore
                   var pinData = pin
                   let docRef = try ref.addDocument(from: pinData)
                   
                   //updates document with the firestore-id
                   docRef.updateData(["id": docRef.documentID])
                   
                   //saves the firestore-id to local list
                   pinData.id = docRef.documentID
                   
                  print("This pin is new, saved pin to Firestore.")
                   //Send the updated pin in the callback if successfull
                  completion(pinData)
               } catch {
                  print("Failed to save new pin to Firestore: \(error.localizedDescription)")
                  completion(nil)
               }
            } else {
               print("This pin already exists on Firestore.")
               completion(nil)
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
    
   //Function to add a rating to a pin to firestore
   //Takes in the pin that is being added along with the rating
   // Returns the new ratingAverage to update UI.
   func addRating(to pin: Pin, rating: Int, completion: @escaping (Bool, Double?) -> Void) {
      guard let pinId = pin.id else {
         print("No pin id")
         completion(false, nil)
         return
      }
      
      //Fetches the whole pin document
      let ref = db.collection("pins").document(pinId)
      
      ref.getDocument { snapshot, error in
         if let error = error {
            print("Error getting pin: \(error.localizedDescription)")
            completion(false, nil)
            return
         }
         
         //from that document it gets the array
         guard let data = snapshot?.data(),
               var existingRatings = data["ratings"] as? [Int] else {
            print("Failed reading array")
            completion(false, nil)
            return
         }
         
         //adds the rating to the array
         existingRatings.append(rating)
         // Calculate new rating average to use in venuePins list and UI for annotation subtitle on map.
         let total = existingRatings.reduce(0, +)
         let newAverageRating = Double(total) / Double(existingRatings.count)
         
         //updates firestore with the updated array
         ref.updateData(["ratings": existingRatings]) { error in
            if let error = error {
               print("Failed to update: \(error.localizedDescription)")
               completion(false, nil)
            } else {
               print("Rating added!")
               completion(true, newAverageRating)
            }
         }
      }
   }
   
   /*
    * Similar function to addRating.
    * Difference being the review-array containing a ReviewData-object, needing to be mapped for Firestore.
    */
    func addReview(pin: Pin, review: String, rating: Int, userName : String, completion: @escaping (Bool) -> Void) {
      guard let pinId = pin.id else {
          print("No pin id")
          completion(false)
          return
      }
      
      // List to hold the fetched reviews from the pin reviews field.
      var existingReviews : [ReviewData] = []
      // Create a new review object from the user's input.
       let newReview = ReviewData(text: review, rating: rating, userName: userName)
      
      // Fetch the pin document data.
      let ref = db.collection("pins").document(pinId)
      ref.getDocument { doc, err in
         if let error = err {
            print("Could not fetch pin for review: \(error.localizedDescription)")
            completion(false)
            return
         }

         // Go through each review dictionary in the array and convert it to a ReviewData object that is added to list existingReviews.
         if let data = doc?.data(),
            let reviews = data["reviews"] as? [[String:Any]] {
            existingReviews = reviews.compactMap { dict in
                guard let text = dict["text"] as? String, let rating = dict["rating"] as? Int, let userName = dict["userName"] as? String else {return nil}
                return ReviewData(text: text, rating: rating, userName: userName)
            }
         }
         // Add the newly created review to the list.
         existingReviews.append(newReview)
         
         // Upload the updated review list, map each ReviewData to a dictionary.
          ref.updateData(["reviews" : existingReviews.map { ["text": $0.text, "rating": $0.rating, "userName": $0.userName ?? "Anonymous"] }]) { err in
            if let error = err {
               print("Error updating reviews field: \(error.localizedDescription)")
               completion(false)
            } else {
               print("Updated reviews field.")
               completion(true)
            }
         }
      }
   }
   
   /*
    * Called in VenueDetailView onAppear to load the reviews for the clicked pin.
    * Listens to changes in this pin, so when a new review is added, the UI is updated.
    */
   func listenToPinReviews(pin: Pin) {
      guard let pinId = pin.id else {
          print("No pin id")
          return
      }
      
      // Set up snapshotlistener for the clicked pin.
      let ref = db.collection("pins").document(pinId)
      ref.addSnapshotListener { snap, err in
         
         if let error = err {
            print("Error listening for review updates: \(error.localizedDescription)")
            return
         }
         // Get data from reviews field as dict.
         guard let data = snap?.data(), let reviews = data["reviews"] as? [[String: Any]] else {
            print("No reviews found or bad format")
            return
         }
         // Convert dicts to ReviewData objects and add to temporary list.
         let tempList = reviews.compactMap { dict -> ReviewData? in
             guard let text = dict["text"] as? String, let rating = dict["rating"] as? Int, let userName = dict["userName"] as? String else {
                 return nil
             }
             return ReviewData(text: text, rating: rating, userName: userName)
         }
         // On main thread, set value from templist to published list used in scrollview in VenueDetailView.
         DispatchQueue.main.async {
            self.pinReviews = tempList
         }
      }
   }
   
}

//
//  MapViewModel.swift
//  BabyBrunch
//
//  Created by KiwiComp on 2025-05-20.
//

import Foundation
import Firebase
import MapKit
import FirebaseAuth
import SwiftUI

class MapViewModel : ObservableObject {
    @Published var venuePins : [String: MKPointAnnotation] = [:]
    @Published var pinReviews : [ReviewData] = []
    @ObservedObject var soundVM = SoundViewModel()
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    
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
                        self.soundVM.playSound(resourceName: "AddPinSound", resourceFormat: "wav")
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
    
    /*
     * Function to add a rating and review to a pin to Firestore.
     * Takes in the pin that is being added along with the rating.
     * Also takes in variables for the review, function to add review is called within this function.
     * Returns the new ratingAverage to update UI.
     * Also callback to trigger alert in UI if user already has rated/left a review.
     */
    func addRating(to pin: Pin, rating: Int, review: String, userName: String, completion: @escaping (Bool, Double?) -> Void, reviewExists: @escaping (Bool) -> Void) {
        guard let userId = auth.currentUser?.uid else {return}
        
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
            
            guard let data = snapshot?.data() else {
                print("No snapshot data")
                completion(false, nil)
                return
            }
            var existingReviews : [ReviewData] = []
            // Use help function to go through each review dictionary in the array and convert it to a ReviewData object, return to list existingReviews.
            existingReviews = self.parseReviews(from: data)
            
            // Check if a review with the userId exists.
            let alreadyLeftAReview = existingReviews.contains { $0.userId == userId }
            // If it returns true (i.e. userId exists), user reviewExists callback to trigger alert in UI. Exit the function.
            if alreadyLeftAReview {
                print("User has already left a review for this pin.")
                completion(false, nil)
                reviewExists(true)
                return
            }
            
            // from the snapshot document, get the ratings array
            guard var existingRatings = data["ratings"] as? [Int] else {
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
                    self.addReview(pin: pin, review: review, rating: rating, userId: userId, userName: userName, existingReviews: existingReviews) { success in
                        if success {
                            completion(true, newAverageRating)
                        } else {
                            completion(false, nil)
                            print("Fail review.")
                        }
                    }
                }
            }
        }
    }
    
    /*
     * Called upon inside addRating function.
     * Takes in pin, userId and all info for the review along with all the existing reviews on Firestore.
     * Callback to trigger callback in addRating.
     */
    func addReview(pin: Pin, review: String, rating: Int, userId: String, userName : String, existingReviews: [ReviewData], completion: @escaping (Bool) -> Void) {
        guard let pinId = pin.id else {
            print("No pin id")
            completion(false)
            return
        }
        
        // Editable list to hold reviews sent into function, fetched from Firestore.
        var updatedReviews = existingReviews
        // Create a new review object from the user's input.
        let newReview = ReviewData(text: review, rating: rating, userId: userId, userName: userName, pinId: pinId, pinName: pin.name)
        updatedReviews.append(newReview)
        
        let ref = db.collection("pins").document(pinId)
        // Update reviews field on Firestore.
        ref.updateData(["reviews" : updatedReviews.map { ["text": $0.text, "rating": $0.rating, "userId": $0.userId, "userName": $0.userName ?? "Anonymous", "pinId": $0.pinId ?? "pinIdError", "pinName": $0.pinName ?? "pinNameError"] }]) { err in
            if let error = err {
                print("Error updating reviews field: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Updated reviews field.")
                completion(true)
            }
        }
    }
    
    /*
     * Function to lighten up code in addRating function.
     */
    func parseReviews(from data: [String:Any]) -> [ReviewData] {
        guard let reviews = data["reviews"] as? [[String:Any]] else {
            return []
        }
        return reviews.compactMap { dict in
            guard let text = dict["text"] as? String,
                  let rating = dict["rating"] as? Int,
                  let userId = dict["userId"] as? String,
                  let userName = dict["userName"] as? String else {return nil}
            let pinId = dict["pinId"] as? String ?? ""
            let pinName = dict["pinName"] as? String ?? ""
            return ReviewData(text: text, rating: rating, userId: userId, userName: userName, pinId: pinId, pinName: pinName)
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
            
            let tempList = reviews.compactMap { dict -> ReviewData? in
                guard
                    let text = dict["text"] as? String,
                    !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,   // Filter away reviews with empty text.
                    let rating = dict["rating"] as? Int,
                    let userName = dict["userName"] as? String
                else {
                    return nil
                }
                return ReviewData(text: text, rating: rating, userId: "", userName: userName, pinId: "", pinName: "")
            }
            // On main thread, set value from templist to published list used in scrollview in VenueDetailView.
            DispatchQueue.main.async {
                self.pinReviews = tempList
            }
        }
    }
    
    //Function to fetch a pin from firestore to use for example when fetching a new averagerating when adding a review.
    func fetchPin(withId id: String, completion: @escaping (Pin?) -> Void) {
        let ref = db.collection("pins").document(id)
        ref.getDocument { snapshot, error in
            if let error = error {
                print("Error fetching pin! \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            do {
                if let snapshot = snapshot, snapshot.exists {
                    let pin = try snapshot.data(as: Pin.self)
                    completion(pin)
                } else {
                    completion(nil)
                }
            } catch {
                print("Error decoding pin: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    /*
     * Fetch all reviews by the current user to be displayed in UserReviewsView.
     */
    func fetchReviewsByCurrentUser(completion: @escaping ([ReviewData]) -> Void) {
        guard let currentUserId = auth.currentUser?.uid else {
            completion([])
            return
        }
        let ref = db.collection("pins")
        ref.getDocuments { snap, err in
            if let error = err {
                print("Error fetching user reviews: \(error.localizedDescription)")
                completion([])
            }
            guard let documents = snap?.documents else {
                completion([])
                return
            }
            // List to hold the user's reviews.
            var userReviews : [ReviewData] = []
            // Iterate over each document in the snapshot documents.
            for document in documents {
                // Decode each document as a Pin object and store the pin's review field in reviews list.
                if let pin = try? document.data(as: Pin.self), let reviews = pin.reviews {
                    // For each review where the userId field is equal to the current user's id, add that review to the userReviewsList.
                    for review in reviews where review.userId == currentUserId {
                        userReviews.append(review)
                    }
                }
            }
            // Send the userReviews list through the callback.
            completion(userReviews)
        }
    }
    
    /*
     * Function to delete a review for a specific pin and the current user id.
     * Bool callback to be used in UserReviewView to then call on removeRating below.
     */
    func deleteReview(pinId: String, completion: @escaping (Bool) -> Void) {
        // Get currentUserId, if none then just return.
        guard let userId = auth.currentUser?.uid else {return}
        let ref = db.collection("pins").document(pinId)
        
        // Get the pin document using the pinId.
        ref.getDocument { snap, err in
            if let error = err {
                print("Could not get pin to delete review: \(error.localizedDescription)")
                completion(false)
            }
            // Guard check the data in the snapshot and the parsing of the reviews array within the data.
            guard let data = snap?.data(), var reviews = data["reviews"] as? [[String: Any]] else {
                print("No data found for pin to delete review.")
                completion(false)
                return
            }
            // Filter the reviews array to only get the ones not containing the current user id, i.e. filter away the one containing the current user id.
            reviews = reviews.filter { $0["userId"] as? String != userId }
            // Update document's reviews field with the filtered list, i.e. the review containing the current user id has been removed.
            ref.updateData(["reviews": reviews]) { err in
                if let error = err {
                    print("Could not remove user review: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("Deleted user review from pin.")
                    completion(true)
                }
            }
        }
    }
    
    /*
     * Called upon in UserReviewsView, if function deleteReview above returns true.
     * Callback returns a bool for success/fail, a double for the new rating average and the pin (to update map with annotation with correct average displayed).
     */
    func removeRating(from pinId: String, ratingToRemove: Int, completion: @escaping (Bool, Double?, Pin?) -> Void) {
        let ref = db.collection("pins").document(pinId)
        
        ref.getDocument { snapshot, error in
            if let error = error {
                print("Error getting pin: \(error.localizedDescription)")
                completion(false, nil, nil)
                return
            }
            guard let data = snapshot?.data(),
                  var ratings = data["ratings"] as? [Int] else {
                print("No data or ratings array")
                completion(false, nil, nil)
                return
            }
            // Remove one instance of the rating, doesn't matter which just the first of a matching rating.
            if let index = ratings.firstIndex(of: ratingToRemove) {
                ratings.remove(at: index)
            } else {
                print("Rating not found in array")
                completion(false, nil, nil)
                return
            }
            // Calcualte new average.
            let newAverage = ratings.isEmpty ? 0.0 : Double(ratings.reduce(0, +)) / Double(ratings.count)
            // Update pin document on Firestore.
            ref.updateData(["ratings": ratings]) { error in
                if let error = error {
                    print("Failed to update: \(error.localizedDescription)")
                    completion(false, nil, nil)
                } else {
                    print("Rating removed successfully")
                    // If update successful, call on fetchPin to be able to use in callback to update annotation on map to display new average.
                    self.fetchPin(withId: pinId) { pin in
                        completion(true, newAverage, pin)
                    }
                }
            }
        }
    }
    
    /*
     * Function to update pin average rating when a review/rating is created or deleted.
     * Check if annotation exists on mapView by comparing pin id.
     * If it exists, cast MKAnnotation to a PinAnnotation and create a new variable storing the data.
     */
    func updateAnnoatation(mapView: MKMapView, pin: Pin, newAverage: Double) {
        // Check if mapView contains annotation with the pinId, which is then stored in oldAnnotation variable.
        if let oldAnnotation = mapView.annotations.first(where: {
            guard let pinAnnotation = $0 as? PinAnnotation else { return false }
            return pinAnnotation.pin?.id == pin.id
        }) as? PinAnnotation, let oldPin = oldAnnotation.pin { // Double check data type of the returned annotation, and check that we can store the pin inside the annotation in variable oldPin to be used to create a new annotation using the information from the "old pin".
            
            // Create a new annotation with the same data as the old pin (using custom init in PinAnnotation).
            let newAnnotation = PinAnnotation(pin: oldPin)
            // Update subtitle with new averageRating sent into this function.
            newAnnotation.subtitle = String(format: "⭐️: %.1f", newAverage)
            
            // On the main thread, remove the old pin from the map and add the new pin instead.
            DispatchQueue.main.async {
                mapView.removeAnnotation(oldAnnotation)
                mapView.addAnnotation(newAnnotation)
            }
        } else {
            print("No existing annotation found to update.")
        }
    }
    
}

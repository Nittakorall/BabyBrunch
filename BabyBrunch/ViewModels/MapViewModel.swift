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

class MapViewModel : ObservableObject {
    @Published var venuePins : [String: MKPointAnnotation] = [:]
    @Published var pinReviews : [ReviewData] = []
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
        let newReview = ReviewData(text: review, rating: rating, userId: userId, userName: userName)
        updatedReviews.append(newReview)
        
        let ref = db.collection("pins").document(pinId)
        // Update reviews field on Firestore.
        ref.updateData(["reviews" : updatedReviews.map { ["text": $0.text, "rating": $0.rating, "userId": $0.userId, "userName": $0.userName ?? "Anonymous"] }]) { err in
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
             return ReviewData(text: text, rating: rating, userId: userId, userName: userName)
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
                return ReviewData(text: text, rating: rating, userId: "", userName: userName)
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
}

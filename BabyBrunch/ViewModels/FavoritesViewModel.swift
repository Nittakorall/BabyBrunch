//
//  FavoritesViewModel.swift
//  BabyBrunch
//
//  Created by Victor Sundberg on 2025-06-02.
//

import Foundation
import Firebase

class FavoritesViewModel: ObservableObject {
    //List of all pins from users favorites
    @Published var favoritePins: [Pin] = []
    let db = Firestore.firestore()
    
    //Function for fetching all favorites pins from users favorites
    func fetchFavorites(from ids: [String]) {
        var fetchedPins: [Pin] = []
        
        //Create a dispatchGroup to run multiple tasks at the same time
        let group = DispatchGroup()
        
        //Loop through all favorite ids
        for id in ids {
            //Starts a tasks within the group
            group.enter()
            db.collection("pins").document(id).getDocument { snapshot, error in
                if let snapshot = snapshot, let pin = try? snapshot.data(as: Pin.self) {
                    fetchedPins.append(pin) // add pins to local list
                }
                //Ends task within group when task is finished
                group.leave()
            }
        }
        
        //Set favorites when all documents are fetched and updatess ui
        //only runs when all enter()s has a leave()
        group.notify(queue: .main) {
            self.favoritePins = fetchedPins.sorted { $0.name < $1.name }
            print("All favorites was loaded!")
        }
    }
    
    func publishFavorites(listName: String, pinIDs: [String]) {
        let ref = db.collection("publicLists").document(listName)
        
        ref.getDocument { snapshot, error in
            if let error = error {
                print("Error checking list name: \(error.localizedDescription)")
                return
            }
            
            //Checks if the document name already exists
            if let snapshot = snapshot, snapshot.exists {
                print("List name already exists")
                //kan läggas till en errortext som kan användas vid alert etc här
            } else {
                //If document name don't exist create a new document with name and array of pins
                let data: [String: Any] = [
                    "name": listName,
                    "pins": pinIDs,
                ]
                
                //save the created document to firestore
                ref.setData(data) { error in
                    if let error = error {
                        print("Failed to publish list \(error.localizedDescription)")
                    } else {
                        print("List \(listName) successfully published!")
                    }
                }
            }
            
        }
    }
}

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
}

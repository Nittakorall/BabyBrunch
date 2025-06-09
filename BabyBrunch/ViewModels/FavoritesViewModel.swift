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
    @Published var publicList: [PublicListData] = []
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
        let charactersToRemove: [Character] = [" ", ".", ",", "'", "´", "\"", "!", "?", "/", "\\", "¨", "^", "<", ">", "=", ":", ";", "|", "@", "#", "$", "%", "&", "(", ")", "[", "]", "{", "}", "*", "+", "~", "`"]
        let normalisedName = listName.lowercased().filter { !charactersToRemove.contains($0) }
        
        let ref = db.collection("publicLists").document(normalisedName)
        
        
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
                    "normalisedName": normalisedName,
                    "pins": pinIDs,
                ]
                print("Listname: \(listName), nornalisedName: \(normalisedName)")
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
    
    /*
     * Function to fetch a public list with user search input.
     * Normalise the search term by removing a list of characters.
     * Add found list to published list publicList, if no list matching normalised search term then empty the list.
     */
    func fetchPublicListFromSearch(for searchTerm: String) {
        let charactersToRemove: [Character] = [" ", ".", ",", "'", "´", "\"", "!", "?", "/", "\\", "¨", "^", "<", ">", "=", ":", ";", "|", "@", "#", "$", "%", "&", "(", ")", "[", "]", "{", "}", "*", "+", "~", "`"]
        let normalisedSearchTerm = searchTerm.lowercased().filter { !charactersToRemove.contains($0) }
        let ref = db.collection("publicLists").document(normalisedSearchTerm)
        
        ref.getDocument { snap, err in
            if let error = err {
                print("Could not get public list document: \(error.localizedDescription)")
                return
            }
            guard let snapshot = snap, snapshot.exists else {
                print("No public list found with ID: \(normalisedSearchTerm)")
                self.publicList.removeAll()
                return
            }
            
            do {
                // Parse Firestore doc data as RawPublicListData and store in variable.
                // Use RawPublicListData to easily get all data in the document.
                let rawListData = try snapshot.data(as: RawPublicListData.self)
                
                // Call function to convert the parsed Firestore data (RawPublicListData) to a PublicListData by fetching each pin using the pinIDs in the array.
                // If successful, callback with a PublicListData containing all the pins.
                self.convertRawPublicList(rawList: rawListData) { publicListData in
                    if let publicList = publicListData {
                        //                        tempList.append(publicList) // Add to temporary list.
                        DispatchQueue.main.async {
                            self.publicList = [publicList]
                        }
                    }
                }
            } catch {
                print("Could not parse snapshot documents: \(error.localizedDescription)")
            }
        }
    }
    
    func convertRawPublicList(rawList: RawPublicListData, completion: @escaping (PublicListData?) -> Void) {
        let pinIDs = rawList.pins
        let ref = db.collection("pins")
        
        var pins: [Pin] = []
        let group = DispatchGroup()
        
        for id in pinIDs {
            group.enter()
            ref.document(id).getDocument { doc, err in
                defer { group.leave() } // Regardless of what happens below (success, fail, whatever), group.leave will run.
                
                if let error = err {
                    print("Could not get pins for public list: \(error.localizedDescription)")
                    return
                }
                
                if let doc = doc, doc.exists {
                    do {
                        let pin = try doc.data(as: Pin.self)
                        pins.append(pin)
                    } catch {
                        print("Could not decode pin: \(error)")
                    }
                    
                } else {
                    print("Pin with ID \(id) not found.")
                }
            }
        }
        // When all group calls are made (and finished), run the code on the main thread.
        group.notify(queue: .main) {
            let publicList = PublicListData(name: rawList.name, pins: pins)
            completion(publicList)
        }
    }
    
}


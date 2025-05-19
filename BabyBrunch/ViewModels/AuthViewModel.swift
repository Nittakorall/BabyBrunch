//
//  AuthViewmodel.swift
//  BabyBrunch
//
//  Created by Victor Sundberg on 2025-05-19.
//

import Foundation
import Firebase
import FirebaseAuth

public class AuthViewmodel {
    let db = Firestore.firestore()
    let auth = Auth.auth()
    
    func saveToFirestore(user: User) {
        let userRef = db.collection("User").document(user.id)
        let userData:[String: Any] = [
            "id": user.id,
            "email": user.email ?? "",
            "favorites": user.favorites ?? "",
            "isSignedUp": user.isSignedUp
        ]
        userRef.setData(userData, merge: true){ error in
            if let err = error {
                print("cant save to fireStore \(err)")
            } else {
                print("saved to fireStore")
            }
        }
    }
    func listenToFirestore(){
        guard let user = auth.currentUser else { return }
        let userRef = db.collection("users").document("\(user.uid)")
        let users = db.collection("users")
        
        userRef.addSnapshotListener { documentSnapshot, error in
            guard let documentSnapshot = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            print("Does it work?")
        }
        
    }
}

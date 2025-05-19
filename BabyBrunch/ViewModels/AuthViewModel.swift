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
        guard let user = auth.currentUser else { return }
        let userRef = db.collection("User") //check if logged in
        let users = db.collection("User")([
            id: user.uid,
            email: user.email ?? "",
            favorites: user.favorites ?? "",
            isAnonymous: user.isAnonymous ?? false
        ])
        do{
            try userRef.get()
        } catch {
            print("Can't save to firestore")
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

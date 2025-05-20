//
//  AuthViewmodel.swift
//  BabyBrunch
//
//  Created by Victor Sundberg on 2025-05-19.
//

import Foundation
import Firebase
import FirebaseAuth

@MainActor
public class AuthViewModel: ObservableObject {
    @Published var currentUser: User? = nil
    @Published var errorMessage: String? = nil
    @Published var isLoggedIn = false
    private var error_: String?
    private var isSignedUp = false
    
    let db = Firestore.firestore()
    let auth = Auth.auth()
    
    func saveUserToFirestore(user: User) {
        let userRef = db.collection("users").document(user.id)
        let userData:[String: Any] = [
            "id": user.id,
            "email": user.email,
            "favorites": user.favorites,
            "register": user.isSignedUp
        ]
        userRef.setData(userData, merge: true){ error in
            if let err = error {
                print("cant save to fireStore \(err)")
            } else {
                print("saved to fireStore")
            }
            
            
            
            // Guest flow
            //            func signInAsGuest() {
            //                Task {
            //                    let result = try await Auth.auth().signInAnonymously()
            //                    finishSignIn(uid: result.user.uid, email: nil, isSignedUp: false)
            //                }
            //            }
        }
    }
    func signUpWithEmail(email: String, password: String, onSuccess: @escaping (Bool) -> Void){
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let err = error {
                print("Fel vid registrering: \(err.localizedDescription)")
                onSuccess(false)
            } else {
                self.isSignedUp = true
                onSuccess(true)
            }
        }
    }
    
    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let err = error {
                print("Sign in failed: \(err)")
            } else {
                self.isLoggedIn = true
            }
        }
    }
}

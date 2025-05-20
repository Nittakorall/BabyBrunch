//
//  AuthViewmodel.swift
//  BabyBrunch
//
//  Created by Victor Sundberg on 2025-05-19.
//

import Foundation
import FirebaseFirestore
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
    
    func saveUser(_ user: User) {
        do {
            try db.collection("users").document(user.id).setData(from: user) { error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("User saved!")
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func signInAsGuest() {
        Auth.auth().signInAnonymously { result, error in
            if let error = error {
                print(error.localizedDescription)
            } else if let user = result?.user {
                let guestUser = User(id: user.uid, isSignedUp: false)
                self.currentUser = guestUser
                self.isLoggedIn = true
            }
        }
    }
    
    func signUpWithEmail(email: String, password: String, onSuccess: @escaping (Bool) -> Void){
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let err = error {
                print("Fel vid registrering: \(err.localizedDescription)")
                onSuccess(false)
            } else if let user = result?.user {
                let newUser = User(id: user.uid, email: email, isSignedUp: true)
                self.saveUser(newUser)
                self.currentUser = newUser
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
                if let user = result?.user {
                    self.isLoggedIn = true
                    self.fetchUserInfo(uid: user.uid)
                }
            }
        }
    }
    
    //Funktion som körs efter du loggat in för att få med all info från userId:t i firestore ex. isSignedUp och favorites
    func fetchUserInfo(uid: String) {
        let docRef = db.collection("users").document(uid)
        docRef.getDocument { document, error in
            if let document = document, document.exists {
                do {
                    let user = try document.data(as: User.self)
                    self.currentUser = user
                } catch {
                    print(error)
                }
            } else {
                print("Document does not exist")
            }
        }
    }
}

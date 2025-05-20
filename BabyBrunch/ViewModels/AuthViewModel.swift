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
    
    //Funktion för att spara användaren som skickas in till firestore under users. varje användare får sitt uid som id
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
    
    //Funktion för att logga in som gäst och få tillgång till appen fast med variabeln isSignedUp som false, som används för att begränsa appen senare.
    //sparar currentUser som den nyskapade guestUser.
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
    
    //Funktion för att skapa ett konto och då få tillgång till hela appen genom isSignedUp = true.
    //Denna user sparas också i firestore för att kunna lagra mer info som favoritlistor etc.
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
    
    //Funktion för att logga in användare som har konto och alltså har tillgång till hela appen
    //Kallar på fetchUserInfo för att få med all data och sätter även där currentUser med hjälp av kontots uid
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
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.isLoggedIn = false
            print("Successfully signed out")
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

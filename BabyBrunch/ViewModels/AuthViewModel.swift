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
    // Reflects the sign‑up status of the *currentUser* for quick access in views.
    @Published var isSignedUp: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isLoggedIn = false
    @Published var authError: AuthErrorHandler? = nil // not in use atm but leaving just in case
    //part of splash screen
    @Published var isActive = false
    
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    
    init() {
        loadLoginState()
        if isLoggedIn, let uid = UserDefaults.standard.string(forKey: "currentUserID") {
            fetchUserInfo(uid: uid)
        }
    }
    
    //Function to save a user that is then sent to firestore under 'users'. Each user gets their uid as id
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
    
    //Function to log in as guest and get access to some app features, isSignedUp is set to false to restrict some access
    //saves currentUser as the newly created guestUser.
    func signInAsGuest() {
        auth.signInAnonymously { [weak self] result, error in guard let self = self else { return }
            if let error = error {
                self.handleErrors(error)
                return
            }
            // prevents crashes in case of e.g. server issues and a guest user is not stored correctly
            guard let user = result?.user else {
                self.handleErrors(NSError(
                    domain: "Auth",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey : "User object missing"] )
                )
                return
            }
            self.currentUser = User(id: user.uid, isSignedUp: false)
            self.isSignedUp = false
            
            UserDefaults.standard.set(user.uid, forKey: "currentUserID")
            self.isLoggedIn = true
        }
    }
    
    //Function to create and account and to then get access to all the app's features through the bool isSignedUp = true.
    //This user is also saved to FIrestor to be able to save stuff like favorites etc
    func signUpWithEmail(email: String, password: String, onSuccess: @escaping (Bool) -> Void = { _ in }) {
        auth.createUser(withEmail: email, password: password) { result, error in
            if let error {
                self.handleErrors(error)
                onSuccess(false)
                return
            }
            guard let user = result?.user else { onSuccess(false); return }
            let newUser = User(id: user.uid, email: email, isSignedUp: true)
            self.saveUser(newUser)
            self.currentUser = newUser
            self.isSignedUp = true
            
            UserDefaults.standard.set(user.uid, forKey: "currentUserID")
            onSuccess(true)
        }
    }
    
    //Function to log in the user who has an account (and therefore has access to the entire app)
    //Calls on fetchUserInfo to get all data and also sets currentUser with the help of uid
    func signIn(email: String, password: String, completion: @escaping (Bool) -> Void = { _ in }) {
        auth.signIn(withEmail: email, password: password) { [weak self] result, error in guard let self = self else { return }
            if let error {
                self.handleErrors(error)
                completion(false)
                return
            }
            // prevents crashes in case of e.g. server issues and a user is not registered correctly
            guard let user = result?.user else {
                self.handleErrors(NSError(
                    domain: "Auth",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey : "User object missing"]))
                completion(false)
                return
            }
            self.isLoggedIn = true
            self.isActive = true
            UserDefaults.standard.set(user.uid, forKey: "currentUserID")
            self.fetchUserInfo(uid: user.uid)
            completion(true)
        }
    }
    
    func loadLoginState() {
        let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        self.isLoggedIn = isLoggedIn
        isSignedUp = UserDefaults.standard.bool(forKey: "isSignedUp")
        self.isSignedUp = isSignedUp
    }
    
    //Function that runs after you have logged in to collect all the info from the userId in fireStore, e.g. isSignedUp och favorites
    func fetchUserInfo(uid: String) {
        let docRef = db.collection("users").document(uid)
        docRef.getDocument { document, error in
            if let document = document, document.exists {
                do {
                    let user = try document.data(as: User.self)
                    self.currentUser = user
                    self.isSignedUp = user.isSignedUp
                    UserDefaults.standard.set(user.isSignedUp, forKey: "isSignedUp") // Kseniia + chatGPT
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
            try auth.signOut()
            self.isLoggedIn = false
            self.currentUser = nil
            
            //part of splash screen
            self.isActive = true
            self.isSignedUp = false // resets the flag so that the user can log in as guest after login out
            authError = nil        // kill any pending alert (to prevent "must sign in..." alert after signing out as guest
            UserDefaults.standard.set(false, forKey: "isLoggedIn")
            UserDefaults.standard.removeObject(forKey: "currentUserID")
        } catch {
            self.handleErrors(error)
        }
    }
    

    func deleteUser(password: String, completion: @escaping (Bool) -> Void) {
        guard let user = auth.currentUser else {
            //            completion(.failure(NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Ingen användare är inloggad."])))
            return
        }
        if let email = user.email{
            
            // Skapa inloggningsuppgifterna
            let credential = EmailAuthProvider.credential(withEmail: email, password: password)
            
            // 1. Reautenticera användaren
            user.reauthenticate(with: credential) { result, error in
                if let error = error {
                    //                    completion(.failure(error))
                    completion(false)
                    return
                }
                
                let db = Firestore.firestore()
                let userID = user.uid
                
                // 2. Radera dokumentet i Firestore
                db.collection("users").document(userID).delete { err in
                    if let err = err {
                        //                        completion(.failure(err))
                        completion(false)
                        return
                    }
                    
                    // 3. Radera användaren från Firebase Authentication
                    user.delete { error in
                        if let error = error {
                            //                            completion(.failure(error))
                            completion(false)
                        } else {
                            print("Användare och Firestore-dokument raderades.")
                            //                            completion(.success(()))
                            completion(true)
                        }
                    }
                }
            }
        }
    }
    
    private func handleErrors(_ error: Error) {
        let mapped = AuthErrorHandler.from(error)
        errorMessage = mapped.localizedDescription
        self.authError = mapped
        print("ErrorHandler:", mapped.localizedDescription)
    }
    
    
    func toggleFavorite(pinId: String, completion: @escaping (Bool) -> Void) {
        guard let uid = currentUser?.id else { return }
        let userRef = db.collection("users").document(uid)
        
        userRef.getDocument { snapshot, error in
            guard let user = try? snapshot?.data(as: User.self) else {
                completion(false)
                return
            }
            
            var updatedFavorites = user.favorites
            if updatedFavorites.contains(pinId) {
                updatedFavorites.removeAll { $0 == pinId }
            } else {
                updatedFavorites.append(pinId)
            }
            
            userRef.updateData(["favorites": updatedFavorites]) { error in
                if let error = error {
                    print("Error updating favorites: \(error.localizedDescription)")
                    completion(false)
                } else {
                    self.currentUser?.favorites = updatedFavorites
                    completion(true)
                }
            }
        }
    }
    
}


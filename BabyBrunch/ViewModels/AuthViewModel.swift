//
//  AuthViewmodel.swift
//  BabyBrunch
//
//  Created by Victor Sundberg on 2025-05-19.
//

import Foundation
import FirebaseAuth

@MainActor
final class AuthViewModel: ObservableObject {
    
    @Published var currentUser: User?
    @Published var isLoggedIn = false
    
    // login and signup function, replace w code from Simon
//    func signUp(email: String, password: String) async throws {
//        let result = try await Auth.auth().createUser(withEmail: email, password: password)
//        finishSignIn(uid: result.user.uid, email: email, isSignedUp: true)
//    }
//    
//    func signIn(email: String, password: String) async throws {
//        let result = try await Auth.auth().signIn(withEmail: email, password: password)
//        finishSignIn(uid: result.user.uid, email: email, isSignedUp: true)
//    }
    
    // Guest flow
    func signInAsGuest() {
        Task {
            let result = try await Auth.auth().signInAnonymously()
            finishSignIn(uid: result.user.uid, email: nil, isSignedUp: false)
        }
    }
    
    // used after it checks if the user is guest or not
    private func finishSignIn(uid: String, email: String?, isSignedUp: Bool) {
        currentUser = User(id: uid, email: email, isSignedUp: isSignedUp)
        isLoggedIn = true
    }

}

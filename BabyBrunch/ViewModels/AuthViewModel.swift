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
    
    //MARK: mock login and signup function tp match the guest sign in, replace w code from Simon
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
    
    // helps to log in the user as either guest or registered user
    private func finishSignIn(uid: String, email: String?, isSignedUp: Bool) {
        currentUser = User(id: uid, email: email, isSignedUp: isSignedUp)
        isLoggedIn = true
    }

}

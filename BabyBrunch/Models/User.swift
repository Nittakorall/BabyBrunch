//
//  User.swift
//  BabyBrunch
//
//  Created by Victor Sundberg on 2025-05-19.
//

import Foundation

struct User: Identifiable, Codable {
    var id: String
    var email: String = ""
    var favorites: [String] = []
    var isSignedUp: Bool
}

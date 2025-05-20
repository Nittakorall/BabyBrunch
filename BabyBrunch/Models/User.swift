//
//  User.swift
//  BabyBrunch
//
//  Created by Victor Sundberg on 2025-05-19.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    let email: String?
    let favorites: [String]?
    let isSignedUp: Bool
}

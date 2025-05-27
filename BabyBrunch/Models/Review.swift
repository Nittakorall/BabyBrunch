//
//  Review.swift
//  BabyBrunch
//
//  Created by test2 on 2025-05-26.
//

import Foundation
import SwiftUI

struct Review: Identifiable {
    let id = UUID()
    let userName: String
    let rating: Double
    let review: String

}

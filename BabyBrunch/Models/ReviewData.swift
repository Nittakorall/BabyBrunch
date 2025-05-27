//
//  ReviewData.swift
//  BabyBrunch
//
//  Created by KiwiComp on 2025-05-26.
//

import Foundation
import FirebaseFirestore

struct ReviewData : Codable, Identifiable {
   @DocumentID var id : String?
   var text : String
   var rating : Int
}

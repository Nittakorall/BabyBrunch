//
//  Pin.swift
//  BabyBrunch
//
//  Created by KiwiComp on 2025-05-20.
//

import Foundation
import FirebaseFirestore

struct Pin : Codable, Identifiable {
   @DocumentID var id : String?
   var name : String = ""
   var streetAddress : String = ""
   var streetNr : String = ""
   var latitude : Double = 0.0
   var longitude : Double = 0.0
   var website : String = ""
   var phone : String = ""
   var ratings : [Int] = []
   var averageRating: Double {
      guard !ratings.isEmpty else { return 0.0 }
      let total = ratings.reduce(0, +)
      return Double(total) / Double(ratings.count)
   }
}

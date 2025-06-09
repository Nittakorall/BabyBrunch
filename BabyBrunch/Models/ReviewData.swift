//
//  ReviewData.swift
//  BabyBrunch
//
//  Created by KiwiComp on 2025-05-26.
//

import Foundation
import FirebaseFirestore

struct ReviewData : Codable, Identifiable, Hashable {
    @DocumentID var id : String?
    var text : String
    var rating : Int
    var userId : String
    var userName : String?
    var pinId : String?
    var pinName : String?
}

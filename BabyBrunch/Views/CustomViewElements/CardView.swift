//
//  CardView.swift
//  BabyBrunch
//
//  Created by test2 on 2025-05-26.
//

import SwiftUI
struct CardView: View {
    let review : Review
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack{
                Text(review.userName)
                    .font(.headline)
                    .padding(.top, 5)
                
                ReviewStarsView(rating: review.rating)
                
                
            }
            Text(review.review)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding(5)
        .frame(width: UIScreen.main.bounds.width * 0.8, height: 100, alignment: .topLeading)
        .background(Color(.thistle))
        .cornerRadius(10)
    }
    
}

struct ReviewStarsView: View {
    var rating : Double
    var body: some View {
        //better be moved to a subview
        if rating < 2.0 {
            Text("⭐️ \(String(format: "%.1f", rating))")
        } else if rating < 3.0 {
            Text("⭐️⭐️ \(String(format: "%.1f", rating))")
        } else if rating < 4.0 {
            Text("⭐️⭐️⭐️ \(String(format: "%.1f", rating))")
        } else if rating < 5.0 {
            Text("⭐️⭐️⭐️⭐️ \(String(format: "%.1f", rating))")
        } else if rating == 5.0 {
            Text("⭐️⭐️⭐️⭐️⭐️ \(String(format: "%.1f", rating))")
        }
    }
}

//#Preview {
//    CardView(review : review)
//}

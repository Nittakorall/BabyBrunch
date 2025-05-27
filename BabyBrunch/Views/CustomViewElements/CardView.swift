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
            Text("\(review.rating)")
//             Image(review.imageName)
//                .resizable()
//                .scaledToFill()
//                .frame(height: 200)
//                .clipped()
//                .cornerRadius(15)

            Text(review.userName)
                .font(.headline)
                .padding(.top, 5)

            Text(review.review)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
        }
        .frame(width: 300)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 5)
    }
}

//#Preview {
//    CardView()
//}

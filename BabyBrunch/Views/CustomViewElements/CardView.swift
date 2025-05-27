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
                
                Text("\(review.rating)")
          
                    
            }
            Text(review.review)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .frame(width: UIScreen.main.bounds.width * 0.8, height: 100, alignment: .leading)
        .padding()
        .background(Color(.thistle))
        .cornerRadius(20)
        .shadow(radius: 5)
    }
    
}

//#Preview {
//    CardView(review : review)
//}

//
//  CustomTitle.swift
//  BabyBrunch
//
//  Created by KiwiComp on 2025-05-23.
//

import SwiftUI

struct CustomTitle: View {
   
   let title : String
   
    var body: some View {
       Text(title)
           .padding(.top, 50)
           .padding(.bottom, 50)
           .fontDesign(.rounded)
           .font(.title)
           .foregroundColor(Color(.oldRose))
    }
}

#Preview {
   CustomTitle(title: "BABYBrunch")
}

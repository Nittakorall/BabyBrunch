//
//  FavouritesView.swift
//  BabyBrunch
//
//  Created by test2 on 2025-05-19.
//

import SwiftUI



struct FavouritesView: View {
    
    
    let testList = ["BabyCafe", "AnotherBabyCafe", "CafeBaby"]
    
    var body: some View {
        ZStack{
            Color("lavenderBlush")
                .ignoresSafeArea()
            
            VStack{
                
                Text("My favourites")
                    .padding(.top, 50)
                    .fontDesign(.rounded)
                    .font(.title)
                    .foregroundColor(Color("oldRose"))
                List() {
                    
                    ForEach(testList, id: \.self) { testItem in
                        VStack{
                            HStack{
                                Text(testItem)
                                Spacer()
                                Text("4.6")
                                
                            }
                            
                        }
                        
                        .padding(.vertical, 20)
                    }
                    .listRowBackground(Color("lavenderBlush"))
                    
                }
                
                .padding(.vertical, 20)
                .scrollContentBackground(.hidden)
                
            }
            
            .frame(maxHeight: .infinity, alignment: .top)
        }
        
    }
    
}

#Preview {
    FavouritesView()
}

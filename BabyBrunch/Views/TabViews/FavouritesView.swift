//
//  FavouritesView.swift
//  BabyBrunch
//
//  Created by test2 on 2025-05-19.
//

import SwiftUI


struct FavouritesView: View {
   
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject var favVM = FavoritesViewModel()
    @State private var selectedPin: Pin? = nil
   
   var body: some View {
      ZStack{
         Color("lavenderBlush")
            .ignoresSafeArea()
         
         VStack{
            CustomTitle(title: "My Favourites")
             
             //List of all pins from users favorites
             List(favVM.favoritePins) { pin in
                 Button {
                     selectedPin = pin //Sets selectedPin to clicked pin to open a sheet
                 } label: {
                     Text(pin.name)
                 }
             }
             .scrollContentBackground(.hidden) // removes ugly background of the list
         }
         .frame(maxHeight: .infinity, alignment: .top)
      }
      .onAppear{
          //Get all users favorites when loading view
          if let favIds = authVM.currentUser?.favorites {
              favVM.fetchFavorites(from: favIds)
          }
      }
       //shows sheet of clicked item
      .sheet(item: $selectedPin) { pin in
          VenueDetailView(pin: pin, mapViewRef: nil)
      }
   }
}

//#Preview {
//   FavouritesView()
//}

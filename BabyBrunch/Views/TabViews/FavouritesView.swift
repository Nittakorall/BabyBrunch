//
//  FavouritesView.swift
//  BabyBrunch
//
//  Created by test2 on 2025-05-19.
//

import SwiftUI
import MapKit


struct FavouritesView: View {
   
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject var favVM = FavoritesViewModel()
    @State private var selectedPin: Pin? = nil
    @Binding var mapViewRef: MKMapView?
    
    @State private var isPublic = false
    @State private var publicListName = ""
   
   var body: some View {
      ZStack{
         Color("lavenderBlush")
            .ignoresSafeArea()
         
         VStack{
             Toggle("Publish list", isOn: $isPublic)
                 .padding()
             
             if isPublic {
                 TextField("List name", text: $publicListName)
                     .textFieldStyle(RoundedBorderTextFieldStyle())
                     .padding()
                 
                 CustomButton(label: "Publish List", backgroundColor: "oldRose", width: 200) {
                     if !publicListName.isEmpty, let favs = authVM.currentUser?.favorites {
                         favVM.publishFavorites(listName: publicListName, pinIDs: favs)
                     }
                 }
             }
             
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
          VenueDetailView(pin: pin, mapViewRef: mapViewRef)
      }
   }
}

//#Preview {
//   FavouritesView()
//}

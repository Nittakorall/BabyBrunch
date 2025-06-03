//
//  MainTabView.swift
//  BabyBrunch
//
//  Created by test2 on 2025-05-19.
//

import SwiftUI
import MapKit

struct MainTabView: View {
   //shows which tab shoud opens by default, uses tags
   @State private var selectedTab = 2
   @StateObject private var locVM : LocationViewModel
    @State private var mapViewRef: MKMapView? = nil
   
   init() {
       _locVM = StateObject(wrappedValue: LocationViewModel())
      UITabBar.appearance().backgroundColor = UIColor(Color(.lavenderBlush))
   }
   
   var body: some View {
      TabView(selection: $selectedTab) {
         ProfileView(locVM: locVM)
            .tabItem {
               Image(systemName: "person.crop.circle.fill")
            }
            .tag(1)
         
          MapView(mapViewRef: $mapViewRef)
            .tabItem {
               Image(systemName: "map.fill")
            }
            .tag(2)
         
          FavouritesView(mapViewRef: $mapViewRef)
            .tabItem {
               Image(systemName: "heart")
            }
            .tag(3)
          PublicFavouritesView(mapViewRef: $mapViewRef)
             .tabItem {
                Image(systemName: "globe")
             }
             .tag(4)
      }.accentColor(Color(.oldRose))
   }
}
#Preview {
   MainTabView()
}

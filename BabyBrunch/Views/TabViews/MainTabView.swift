//
//  MainTabView.swift
//  BabyBrunch
//
//  Created by test2 on 2025-05-19.
//

import SwiftUI

struct MainTabView: View {
   //shows which tab shoud opens by default, uses tags
   @State private var selectedTab = 2
   
   
   init() {
      UITabBar.appearance().backgroundColor = UIColor(Color(.lavenderBlush))
   }
   
   var body: some View {
      TabView(selection: $selectedTab) {
         ProfileView()
            .tabItem {
               Image(systemName: "person.crop.circle.fill")
            }
            .tag(1)
         
         MapView()
            .tabItem {
               Image(systemName: "map.fill")
            }
            .tag(2)
         
         FavouritesView()
            .tabItem {
               Image(systemName: "heart")
            }
            .tag(3)
      }.accentColor(Color(.oldRose))
   }
}
#Preview {
   MainTabView()
}

//
//  MainTabView.swift
//  BabyBrunch
//
//  Created by test2 on 2025-05-19.
//

import SwiftUI

struct MainTabView: View {
   


                var body: some View {
                    TabView {
                    ProfileView()
                            .tabItem {
                            Label("Profile", systemImage: "person.crop.circle.fill")
                        }
                    
                        MapView()
                            .tabItem {
                                Label("Map", systemImage: "map.fill")
                            }
                           // .badge("!")

                        FavouritesView()
                            .tabItem {
                                Label("Favourites", systemImage: "heart.fill")
                            }
                    }
                }
            }
    #Preview {
        MainTabView()
    }


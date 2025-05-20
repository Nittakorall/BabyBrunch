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
    
    //Cince swiftUI doesn't let to change the color of inactive tab, added UIKit that was supposed to be in appDelegate
    init() {
        let appearance = UITabBarAppearance()
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(named: "raisinBlack")
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(named: "oldRose")
        UITabBar.appearance().standardAppearance = appearance
        //add rows below if you want to add background to tabView
        
      //  if #available(iOS 15.0, *) {
         //   UITabBar.appearance().scrollEdgeAppearance = appearance
        //}
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
                    }
                }
            }
    #Preview {
        MainTabView()
    }

//
//  MainTabView.swift
//  BabyBrunch
//
//  Created by test2 on 2025-05-19.
//

import SwiftUI

struct MainTabView: View {
   
//        init() {
//                    let appearance = UITabBarAppearance()
//                    appearance.configureWithOpaqueBackground()
//           // appearance.backgroundColor = UIColor(named: "tabViewLight")
//             //       appearance.shadowColor = UIColor.black.withAlphaComponent(0.2)
//
//                    UITabBar.appearance().standardAppearance = appearance
//                    if #available(iOS 15.0, *) {
//                        UITabBar.appearance().scrollEdgeAppearance = appearance
//                    }
//                }

                var body: some View {
                    TabView {
                    ProfileView()                       .tabItem {
                            Label("Profile", systemImage: "circle")
                        }
                    
                        MapView()
                            .tabItem {
                                Label("Explore", systemImage: "circle")
                            }
                            .badge("!")

//                    //    SignUpView()
//                            .tabItem {
//                                Label("Favourites", systemImage: "circle")
//                            }
                    }
                }
            }
    #Preview {
        MainTabView()
    }


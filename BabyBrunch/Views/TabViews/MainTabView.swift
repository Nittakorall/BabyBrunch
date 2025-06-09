//
//  MainTabView.swift
//  BabyBrunch
//
//  Created by test2 on 2025-05-19.
//

import SwiftUI
import MapKit
import FirebaseAuth

struct MainTabView: View {
    //shows which tab shoud opens by default, uses tags
    @State private var selectedTab = 2
    @StateObject private var locVM : LocationViewModel
    @State private var mapViewRef: MKMapView? = nil
    @EnvironmentObject private var authVM: AuthViewModel
    
    
    init() {
        _locVM = StateObject(wrappedValue: LocationViewModel())
        let appearance = UITabBarAppearance() // Create instance of UITabBarAppearance to enable custom modifications.
        appearance.configureWithOpaqueBackground() // Make background opaque to enable setting own background.
        appearance.backgroundColor = UIColor(Color(.lavenderBlush)) // Set background to lavenderBlush.
        appearance.shadowColor = .clear // Remove the gray line above the tabview.
        
        // Set custom UITabBarAppearance for both standard and when list is scrolled below tab view.
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
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
            if Auth.auth().currentUser?.isAnonymous == false || authVM.currentUser?.isSignedUp == true {
                
                FavouritesView(mapViewRef: $mapViewRef)
                    .tabItem {
                        Image(systemName: "heart")
                    }
                    .tag(3)
                UserReviewsView(mapViewRef: $mapViewRef)
                    .tabItem {
                        Image(systemName: "rectangle.and.pencil.and.ellipsis")
                    }
                    .tag(4)
                PublicFavouritesView(mapViewRef: $mapViewRef)
                    .tabItem {
                        Image(systemName: "globe")
                    }
                    .tag(5)
            }
        }.accentColor(Color(.oldRose))
            .onAppear(){
                if authVM.currentUser?.isSignedUp == true  {
                    print("Kseniia, currentUser signed up")
                } else {
                    print("Kseniia, currentUser not signed up")
                }
            }
    }
}

#Preview {
    MainTabView()
}

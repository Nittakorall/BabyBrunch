//
//  MapView.swift
//  BabyBrunch
//
//  Created by KiwiComp on 2025-05-19.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
   @State private var mapViewRef: MKMapView? = nil
   @State private var selectedVenue : MKMapItem? = nil
   
   @State private var showAlert = false
   @State private var alertTitle = ""
   @State private var alertMessage = ""
   @State private var showSheet = false
   
   var body : some View {
      UIKitMapView(
         showAlert: $showAlert,
         alertTitle: $alertTitle,
         alertMessage: $alertMessage,
         mapViewRef: $mapViewRef,
         selectedVenue: $selectedVenue)
      .ignoresSafeArea()
      .alert(isPresented: $showAlert) {
         Alert(
            title: Text(alertTitle),
            message: Text(alertMessage),
            primaryButton: .default(Text("Yes"), action: {
               
            }),
            secondaryButton: .cancel(Text("Cancel"))
         )
      }
   }
}

//#Preview {
//    MapView()
//}

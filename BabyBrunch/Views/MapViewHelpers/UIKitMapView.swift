//
//  UIKitMapView.swift
//  BabyBrunch
//
//  Created by KiwiComp on 2025-05-19.
//

import SwiftUI
import MapKit
//import CoreLocation

struct UIKitMapView : UIViewRepresentable {
    @Binding var showAlert: Bool
    @Binding var alertTitle : String
    @Binding var alertMessage: String
    @Binding var mapViewRef: MKMapView?
    @Binding var selectedVenue : MKMapItem?
    
          
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            showAlert: $showAlert,
            alertTitle: $alertTitle,
            alertMessage: $alertMessage,
            selectedVenue: $selectedVenue)
    }
    
    func makeUIView(context: Context) -> MKMapView { // Denna behövs för att UIKitMapView ska kunna ör att fullfölja kraven i protokollet UIViewRepresentable.
        /*
         ✅ Skapar en karta.
         ✅ Kopplar den till en delegat så du kan styra och lyssna.
         ✅ Visar användarens plats.
         ✅ Visar intressanta platser som butiker och restauranger direkt på kartan.
         */
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        //       mapView.pointOfInterestFilter = .includingAll // Visar alla "Points of Interest" (POIs) på kartan.
        mapView.pointOfInterestFilter = MKPointOfInterestFilter(including: [.restaurant, .cafe]) // Visar bara POI som är restauranger eller caféer.
        mapViewRef = mapView
        
        /*
         ✅ Skapar en tryckigenkänning på kartan
         ✅ Kräver bara ett tryck med ett finger
         ✅ Blockerar inte kartans inbyggda interaktioner
         ✅ Kopplar till Coordinator för logik och hantering
         ✅ Lägger till detta på MKMapView
         */
        let tapRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:))) // Skapar en ny UITapGestureRecognizer – ett UIKit-objekt som reagerar på tryck (tap) på skärmen. Den kommer att anropa funktionen handleTap(_:) i din Coordinator-klass när trycket känns av. target: Det objekt vars metod ska köras – här är det context.coordinator, alltså din Coordinator-instans (en brygga mellan SwiftUI och UIKit). action: Vilken metod som ska anropas när trycket sker. #selector(Coordinator.handleTap(_:)) refererar till en Objective-C-kompatibel metod i din Coordinator.
        tapRecognizer.numberOfTapsRequired = 1 // Anger att det räcker med ett tap för att gesten ska kännas igen. Detta är standardvärdet, men det skrivs ofta ut för tydlighet.
        tapRecognizer.numberOfTouchesRequired = 1 // Anger att endast en finger-touch krävs. Om du satte detta till 2, skulle gesten endast kännas igen när två fingrar trycker samtidigt.
        tapRecognizer.cancelsTouchesInView = false // Detta styr om den här gestigenkännaren förhindrar andra touch-händelser från att gå vidare till underliggande vyer. Satt till false betyder att andra interaktioner (t.ex. scrolla eller zooma på kartan) inte blockeras av tap-recognizern.
        tapRecognizer.delegate = context.coordinator // Sätter Coordinator som delegat för gestigenkännaren.
        mapView.addGestureRecognizer(tapRecognizer) // Lägger till tap-recognizern till mapView, så att den lyssnar på användarens tryck.
        
        /*
         ✅ Skapar en region (centrerad på Uppsala).
         ✅ Definierar zoomnivån via span.
         ✅ Ställer in kartan att visa just det området.
         ✅ Returnerar kartan så att den kan visas i din SwiftUI-layout.
         */
        let region = MKCoordinateRegion( // Du skapar ett nytt objekt av typen MKCoordinateRegion. Det används av MKMapView för att definiera vilken del av kartan som ska visas.
            center: CLLocationCoordinate2D(latitude: 59.8609, longitude: 17.6486), // Uppsala
            //         center: CLLocationCoordinate2D(latitude: 59.325, longitude: 18.05), // Stockholm
            //         center: CLLocationCoordinate2D(latitude: 57.706, longitude: 11.954), // Göteborg
            //         center: CLLocationCoordinate2D(latitude: 56.04673, longitude: 12.69437), // Helsingborg
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
        mapView.setRegion(region, animated: false) // Du instruerar MKMapView att visa just den region du nyss skapat. setRegion(_:animated:) är en metod som uppdaterar kartans vy. animated: false betyder att den direkt hoppar till regionen utan animering (ingen zoom eller glidning). Sätter du animated: true, kommer kartan animera sig själv till den nya platsen, vilket kan vara trevligare för användaren.
        
        return mapView // Du returnerar det nykonfigurerade MKMapView-objektet från makeUIView(context:) i UIViewRepresentable. Den här kartan kommer att visas i din SwiftUI-vy.
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) { } // Denna behövs för att UIKitMapView ska kunna ör att fullfölja kraven i protokollet UIViewRepresentable.
    
    
}



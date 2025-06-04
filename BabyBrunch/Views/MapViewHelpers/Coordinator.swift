//
//  Coordinator.swift
//  BabyBrunch
//
//  Created by KiwiComp on 2025-05-19.
//

import Foundation
import SwiftUI
import MapKit
import FirebaseAuth

class Coordinator: NSObject, MKMapViewDelegate, UIGestureRecognizerDelegate {

    var parent : UIKitMapView
    //Stores which pin was last tapped to detect double taps and open a detail view
    private var lastSelectedAnnotation: MKAnnotation?
    
    let authVM: AuthViewModel
    
    @Binding var showAlert: Bool
    @Binding var alertTitle : String
    @Binding var alertMessage: String
    @Binding var selectedVenue : MKMapItem?
    @StateObject var vm = LocationViewModel()
    @Binding var selectedPin: Pin?
    /*
     In classes, you must write an init(...) manually where you bind @Binding variables yourself.
     @Binding is just a wrapper, and you must use _variableName = ... to bind it.
     Note how we use underscores (_showAlert) to assign bindings to properties.
     */
    init(
        parent: UIKitMapView,
        showAlert: Binding<Bool>,
        alertTitle: Binding<String>,
        alertMessage: Binding<String>,
        selectedVenue: Binding<MKMapItem?>,
        selectedPin: Binding<Pin?>,
        authVM: AuthViewModel) {
            self.parent = parent
            _showAlert = showAlert
            _alertTitle = alertTitle
            _alertMessage = alertMessage
            _selectedVenue = selectedVenue
            _selectedPin = selectedPin
            self.authVM = authVM
        }
    
    let region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 59.8609, longitude: 17.6486),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    /*
     This function:
     ✅ Runs when the user taps on the map.
     ✅ Gets the screen location (in pixels) of the tap.
     ✅ Converts it to a real latitude/longitude.
     ✅ You can then use the coordinate to:
     Search nearby
     Add a pin
     Show information
     And more.
     */
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        guard !(annotation is MKUserLocation) else { return nil}
        let identifier = "customPin"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil{
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.calloutOffset = CGPoint(x: 0, y: 25) //move callout up and down
            let pinView = MapPinView()
            let controller = UIHostingController(rootView: pinView)
            controller.view.frame = CGRect(x: 0, y: 0, width: 40, height: 70) //size on the callout
            controller.view.backgroundColor = .clear
            let renderer = UIGraphicsImageRenderer(size: controller.view.bounds.size)
            let image = renderer.image { context in
                controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)}
            annotationView?.image = image
            annotationView?.centerOffset = CGPoint(x: 0, y: -35) //-35 to make the point at the coordinate
            
            //Kallar på handleAnnotationTap vid klick på annotationviewen
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleAnnotationTap(_:)))
            annotationView?.addGestureRecognizer(tap)
            
        } else {
            annotationView?.annotation = annotation
        }
        return annotationView
    }
    
    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) { // @objc: Gör funktionen tillgänglig för Objective-C runtime – nödvändigt för att koppla den till t.ex. en UITapGestureRecognizer. handleTap: Namnet på funktionen som körs när användaren trycker på kartan. gestureRecognizer: UITapGestureRecognizer: Det objekt som skickas in när en "tap" har upptäckts.
        
        parent.vm.mapShouldBeUpdated = false
        
        guard let mapView = gestureRecognizer.view as? MKMapView else { return } // gestureRecognizer.view: Ger dig den UIView som gesterna sker på. as? MKMapView: Försöker type-casta till en MKMapView. guard let ... else { return }: Om casten misslyckas (dvs. om gesten inte sker på en karta), så avslutas funktionen direkt. Detta skyddar koden från att krascha.✅ Resultat: Nu har du en referens till den karta (mapView) som användaren tryckt på.
        let location = gestureRecognizer.location(in: mapView) // gestureRecognizer.location(in: mapView): Hämtar x/y-koordinaten (i pixlar) för var på mapView användaren tryckt.
        
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView) // mapView.convert(...): Översätter CGPoint-positionen (i pixlar) till en CLLocationCoordinate2D, alltså en latitud och longitud. toCoordinateFrom: mapView: Säger att konverteringen ska utgå från det koordinatsystemet som kartan har. ✅ Resultat: Du har nu en CLLocationCoordinate2D (ex: lat: 59.86, long: 17.64) – alltså den exakta geografiska platsen där användaren tryckte.
        let tappedCoordinate = coordinate
      
       //Stops search and prevents adding a new pin if user tapped on an existing pin
        if let tappedView = mapView.hitTest(location, with: nil),
           tappedView is MKAnnotationView {
            return
        }
        
        //checks if the user is guest before searching.
        if Auth.auth().currentUser?.isAnonymous == true || authVM.currentUser?.isSignedUp == false {
            DispatchQueue.main.async {
                self.authVM.authError = .guestNotAllowed
            }
            return
        }
       
        let span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
        let smallRegion = MKCoordinateRegion(center: tappedCoordinate, span: span)
        /*
         This code:
         ✅ Creates a search request object.
         ✅ Limits the search to the visible map area.
         ✅ Includes all types of POIs.
         ✅ Filters for restaurants.
         */
        let request = MKLocalPointsOfInterestRequest(coordinateRegion: smallRegion)
        request.pointOfInterestFilter = MKPointOfInterestFilter(including: [.restaurant, .cafe])
        
        
        
        /*
         ✅ You send the search request to Apple Maps using search.start(...).
         ✅ You wait asynchronously for the result.
         ✅ When the result arrives:
         - If places are found: you get them via response.mapItems.
         - If an error occurs: you print the error to the console.
         */
        let search = MKLocalSearch(request: request) // Du skapar en instans av MKLocalSearch och ger den en sökförfrågan (request) som du tidigare konfigurerat. Det är nu du förbereder själva sökningen som ska köras. Tänk på detta som att du skriver in något i Apple Maps appen – men ännu inte tryckt "Sök".
        search.start { response, error in // Den här raden startar själva sökningen. Den körs asynkront (i bakgrunden). Det betyder: du skickar sökningen, och när resultatet kommer tillbaka körs det som finns inom { ... } (slutklamrarna). Du får tillbaka två saker: response: Svaret från Apple Maps om platser den hittade. error: Ett eventuellt fel som uppstod under sökningen. 💡 Viktigt: Detta är en closure, vilket i Swift är som en liten funktion du skickar med och som körs senare.
            guard let items = response?.mapItems else { return } // response?.mapItems: Om svaret (response) existerar, hämtar vi listan över resultat (mapItems). mapItems är en array av MKMapItem – varje ett sådant representerar en plats, t.ex. en restaurang. guard let ... else { return }: Om mapItems inte finns (dvs. om response är nil), så avbryts funktionen direkt.
            if let error = error {
                print("Sökfel: \(error.localizedDescription)")
                return
            }
                        
            /*
             ✅ Finds the MKMapItem in items that is closest to where the user tapped on the map.
             ✅ Creates an annotation for that place.
             ✅ Displays it as a pin on the map.
             */
            if let nearest = items.min(by: { // items är en array av MKMapItem (resultat från en MKLocalSearch). .min(by:) returnerar det minsta elementet baserat på ett jämförelsekriterium. Det du skickar in i { ... } är en jämförelse mellan två MKMapItem-objekt, där du säger --> a är mindre än b om a ligger närmare coordinate än b. $0 och $1 är två MKMapItem-objekt. placemark.coordinate hämtar CLLocationCoordinate2D för varje. .distance(to:) är en custom extension (definierad i din kod) som räknar ut avståndet i meter mellan två koordinater. 📌 Resultat: Du får det MKMapItem-objekt som ligger närmast coordinate. Om vi hittade någon plats (dvs. items var inte tom), då: Gå in i blocket. Annars → ignorera.
                $0.placemark.coordinate.distance(to: coordinate) <
                    $1.placemark.coordinate.distance(to: coordinate)
            }) {
              
              //Check for if a pin with the same name within the given distance already exists. currently set at 30 meters around.
             //If it already exists return out of the tapGesture again.
             let pinAlreadyExists = mapView.annotations.contains(where: { annotation in
                 guard let title = annotation.title ?? nil else { return false }
                 
                 let sameName = title == nearest.name
                 let closeDistance = annotation.coordinate.distance(to: nearest.placemark.coordinate) < 30
                 
                 return sameName && closeDistance
             })
             
             if pinAlreadyExists {
                 print("Pin already exists")
                 return
             }
                
                DispatchQueue.main.async { // Du gör detta för att uppdatera UI:t på huvudtråden. Exempelvis: lägga till en pin på kartan.
             //       self.vm.mapShouldBeUpdated = false
                    self.selectedVenue = nearest
                    self.alertTitle = nearest.placemark.name ?? "Unknown"
                    self.alertMessage = "Do you want to add a pin for \(nearest.placemark.name ?? "Unknown")?"
                    self.showAlert = true
                }
            }
        }
    }
    
    //Called when a pin is tapped and stores the last tapped pin to track double taps
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        lastSelectedAnnotation = view.annotation
    }
    
    
    //Keeps track of which pin was tapped and whether it was the first or second tap
    @objc func handleAnnotationTap(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view as? MKAnnotationView,
              let annotation = view.annotation as? PinAnnotation,
              let pin = annotation.pin else { return }
        
        //Check if the tap is on the same pin as last time
        guard let last = lastSelectedAnnotation,
              last === annotation else {
            return
        }
        
        //Triggers a sheet in MapView if it's the second tap on the same pin
        selectedPin = pin
    }
}



extension CLLocationCoordinate2D {
    func distance(to other: CLLocationCoordinate2D) -> CLLocationDistance {
        // This defines an instance method called distance(to:) that returns a CLLocationDistance (which is just a typealias for Double – the distance in meters.) The parameter 'other' is the coordinate you want to compare with.
        // Create CLLocation instances. These are converted from CLLocationCoordinate2D to CLLocation,
        // because only CLLocation has the .distance(from:) method.
        // CLLocationCoordinate2D does not natively support distance calculation, but CLLocation does.
        let a = CLLocation(latitude: latitude, longitude: longitude) // 'self' (the coordinate this method is called on) becomes point A.
        let b = CLLocation(latitude: other.latitude, longitude: other.longitude) // 'other' becomes point B.

        // Use CLLocation's method .distance(from:) to calculate the distance in meters between A and B.
        return a.distance(from: b)
    }
}

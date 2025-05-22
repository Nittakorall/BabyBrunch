//
//  Coordinator.swift
//  BabyBrunch
//
//  Created by KiwiComp on 2025-05-19.
//

import Foundation
import SwiftUI
import MapKit

class Coordinator: NSObject, MKMapViewDelegate, UIGestureRecognizerDelegate {

    var parent : UIKitMapView
    
    @Binding var showAlert: Bool
    @Binding var alertTitle : String
    @Binding var alertMessage: String
    @Binding var selectedVenue : MKMapItem?
    @StateObject var vm = LocationViewModel()
    /*
     I klasser måste du själv skriva en init(...) där du binder @Binding-variablerna manuellt. @Binding är bara en "wrapper", och du måste deklarera den med _variabelnamn = ....
     Notera hur vi använder understreck (_showAlert) för att koppla bindningen till egenskaperna.
     */
    init(
        parent: UIKitMapView,
        showAlert: Binding<Bool>,
        alertTitle: Binding<String>,
        alertMessage: Binding<String>,
        selectedVenue: Binding<MKMapItem?>) {
            self.parent = parent
            _showAlert = showAlert
            _alertTitle = alertTitle
            _alertMessage = alertMessage
            _selectedVenue = selectedVenue
        }
    
    let region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 59.8609, longitude: 17.6486),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    /*
     Denna funktion:
     ✅ Körs när användaren trycker på kartan.
     ✅ Hämtar platsen (i pixlar) där användaren tryckte.
     ✅ Översätter den till en riktig latitud/longitud.
     ✅ Du kan sedan använda coordinate för att:
     Söka i närheten
     Lägga till en pin
     Visa information
     Med mera.
     */
    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) { // @objc: Gör funktionen tillgänglig för Objective-C runtime – nödvändigt för att koppla den till t.ex. en UITapGestureRecognizer. handleTap: Namnet på funktionen som körs när användaren trycker på kartan. gestureRecognizer: UITapGestureRecognizer: Det objekt som skickas in när en "tap" har upptäckts.
        
        parent.vm.mapShouldBeUpdated = false
        
        guard let mapView = gestureRecognizer.view as? MKMapView else { return } // gestureRecognizer.view: Ger dig den UIView som gesterna sker på. as? MKMapView: Försöker type-casta till en MKMapView. guard let ... else { return }: Om casten misslyckas (dvs. om gesten inte sker på en karta), så avslutas funktionen direkt. Detta skyddar koden från att krascha.✅ Resultat: Nu har du en referens till den karta (mapView) som användaren tryckt på.
        let location = gestureRecognizer.location(in: mapView) // gestureRecognizer.location(in: mapView): Hämtar x/y-koordinaten (i pixlar) för var på mapView användaren tryckt.
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView) // mapView.convert(...): Översätter CGPoint-positionen (i pixlar) till en CLLocationCoordinate2D, alltså en latitud och longitud. toCoordinateFrom: mapView: Säger att konverteringen ska utgå från det koordinatsystemet som kartan har. ✅ Resultat: Du har nu en CLLocationCoordinate2D (ex: lat: 59.86, long: 17.64) – alltså den exakta geografiska platsen där användaren tryckte.
        let tappedCoordinate = coordinate
      
       //This check stops the tap search from going off if its close to a nearby annotation. Currently set at 5 meters around.
       //If its on a POI that already has a pin then returns out of the tapGesture
       let nearbyAnnotations = mapView.annotations.filter {
           $0.coordinate.distance(to: tappedCoordinate) < 5
       }
       
       if !nearbyAnnotations.isEmpty {
           print("Tap on pin ignore POI search")
           return
       }
       
        let span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
        let smallRegion = MKCoordinateRegion(center: tappedCoordinate, span: span)
        /*
         Den här koden:
         ✅ Skapar ett sökobjekt (en förfrågan).
         ✅ Begränsar sökningen till den synliga kartytan.
         ✅ Inkluderar alla typer av POI.
         ✅ Letar efter restauranger.
         */
        let request = MKLocalPointsOfInterestRequest(coordinateRegion: smallRegion)
        request.pointOfInterestFilter = MKPointOfInterestFilter(including: [.restaurant, .cafe])
        
        /*
         ✅ Du skickar iväg sökningen till Apple Maps med search.start(...).
         ✅ Du väntar asynkront på svar.
         ✅ När svaret kommer:
         - Om svaret innehåller platser: du hämtar dem via response.mapItems.
         - Om något går fel: du skriver ut felet i konsolen.
         */
        let search = MKLocalSearch(request: request) // Du skapar en instans av MKLocalSearch och ger den en sökförfrågan (request) som du tidigare konfigurerat. Det är nu du förbereder själva sökningen som ska köras. Tänk på detta som att du skriver in något i Apple Maps appen – men ännu inte tryckt "Sök".
        search.start { response, error in // Den här raden startar själva sökningen. Den körs asynkront (i bakgrunden). Det betyder: du skickar sökningen, och när resultatet kommer tillbaka körs det som finns inom { ... } (slutklamrarna). Du får tillbaka två saker: response: Svaret från Apple Maps om platser den hittade. error: Ett eventuellt fel som uppstod under sökningen. 💡 Viktigt: Detta är en closure, vilket i Swift är som en liten funktion du skickar med och som körs senare.
            guard let items = response?.mapItems else { return } // response?.mapItems: Om svaret (response) existerar, hämtar vi listan över resultat (mapItems). mapItems är en array av MKMapItem – varje ett sådant representerar en plats, t.ex. en restaurang. guard let ... else { return }: Om mapItems inte finns (dvs. om response är nil), så avbryts funktionen direkt.
            if let error = error {
                print("Sökfel: \(error.localizedDescription)")
                return
            }
                        
            /*
             ✅ Hitta den plats (MKMapItem) i items som ligger närmast den plats du tryckte på i kartan – alltså coordinate.
             ✅ Skapar en annotation för den platsen
             ✅ Visar den som en pin på kartan
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
}



extension CLLocationCoordinate2D {
    func distance(to other: CLLocationCoordinate2D) -> CLLocationDistance { // Du skapar en instansmetod kallad distance(to:). Den returnerar CLLocationDistance (vilket är bara en typalias för Double – avstånd i meter). Parametern other är den koordinat du vill jämföra med.
        // Skapa CLLocation-instanser. Dessa omvandlas till CLLocation, eftersom endast CLLocation har .distance(from:)-metoden. CLLocationCoordinate2D har inte inbyggt stöd för att räkna avstånd. Men CLLocation har det.
        let a = CLLocation(latitude: latitude, longitude: longitude) // self (dvs. den aktuella CLLocationCoordinate2D som du anropar metoden på) blir punkt a.
        let b = CLLocation(latitude: other.latitude, longitude: other.longitude) // other är punkt b.
        return a.distance(from: b) // Använder CLLocation’s metod .distance(from:) för att beräkna avstånd i meter mellan a och b.
    }
}

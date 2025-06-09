//
//  SearchLocationViewModel.swift
//  BabyBrunch
//
//  Created by KiwiComp on 2025-06-04.
//

import Foundation

class SearchLocationViewModel: ObservableObject {
    // Stores a city's coordinates through the json response, is then used in UIKitMapView, in func updateUIView to update map to the coordinates of the city the user typed into the search bar.
    @Published var coordinates: (lat: Double, lon: Double)?
    
    // Get the api key through enum Secrets below.
    let apiKey = Secrets.apiKey
    let baseUrl = "https://api.weatherapi.com/v1/forecast.json"
    
    @MainActor
    func fetchCoordinates(for city: String) async {
        // Used to easily create url for a city when user searches for it in search bar. Rephrases e.g. "New York" to "New%20York" to be used in a url.
        let cityUrl = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "London"
        // Variabel for full url, combining all necessary variables.
        let urlString = "\(baseUrl)?key=\(apiKey)&q=\(cityUrl)&days=1&aqi=no&alerts=no"
        guard let url = URL(string: urlString) else { return }
        
        do {
            // Make an HTTP call to the url.
            let (data, _) = try await URLSession.shared.data(from: url)
            // Create a JSONDecoder instance.
            let decoder = JSONDecoder()
            // Use the decoder to decode the data fetched from Url above as a SimpleLocationResponse.
            let decodedLocation = try decoder.decode(SimpleLocationResponse.self, from: data)
            // Set the published coordinates tuple variable with the lat and lon from the decoded data.
            self.coordinates = (decodedLocation.location.lat, decodedLocation.location.lon)
        } catch {
            print("Failed to fetch coordinates: \(error.localizedDescription)")
        }
    }
}

// To store response from HTTP call.
struct SimpleLocationResponse: Codable {
    // To decode the json response using only the location in the response.
    let location: SimpleLocation
}

struct SimpleLocation: Codable {
    // To decode the lat lon in  the json response.
    let lat: Double
    let lon: Double
}

// To hide api key.
enum Secrets {
    // Computed propery to return a string (the api key).
    // Gets the api key directly from the plist.
    static var apiKey: String {
        // Search the app's bundle for a plist with the name "Secrets".
        guard let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
              // Tries to read the content as raw data.
              let data = try? Data(contentsOf: url),
              // Tries to decode the data as a dictionary.
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
              // Stores the key in the variable if a key named API_KEY is found.
              let key = plist["API_KEY"] as? String else {
            fatalError("API_KEY not found in Secrets.plist")
        }
        // If everything is successful in the guard above, return the key (string).
        // Used to set the apiKey variable in SearchLocationViewModel above.
        return key
    }
}

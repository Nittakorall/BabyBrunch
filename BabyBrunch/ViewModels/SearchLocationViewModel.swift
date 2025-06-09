//
//  SearchLocationViewModel.swift
//  BabyBrunch
//
//  Created by KiwiComp on 2025-06-04.
//

import Foundation

class SearchLocationViewModel: ObservableObject {
    @Published var coordinates: (lat: Double, lon: Double)?
    
    let apiKey = Secrets.apiKey
    let baseUrl = "https://api.weatherapi.com/v1/forecast.json"
    
    @MainActor
    func fetchCoordinates(for city: String) async {
        let cityUrl = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "London"
        let urlString = "\(baseUrl)?key=\(apiKey)&q=\(cityUrl)&days=1&aqi=no&alerts=no"
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            let decodedLocation = try decoder.decode(SimpleLocationResponse.self, from: data)
            self.coordinates = (decodedLocation.location.lat, decodedLocation.location.lon)
            print("Lat: \(decodedLocation.location.lat), Lon: \(decodedLocation.location.lon)")
            
        } catch {
            print("Failed to fetch coordinates: \(error.localizedDescription)")
        }
    }
}

struct SimpleLocationResponse: Codable {
    let location: SimpleLocation
}

struct SimpleLocation: Codable {
    let lat: Double
    let lon: Double
}

enum Secrets {
    static var apiKey: String {
        guard let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
              let key = plist["API_KEY"] as? String else {
            fatalError("API_KEY not found in Secrets.plist")
        }
        return key
    }
}

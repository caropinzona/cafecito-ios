import Foundation
import MapKit
import FirebaseFirestore

class ShopDiscoveryManager: NSObject, ObservableObject {
    private let db = Firestore.firestore()
    
    // Search for coffee shops using Apple's MKLocalSearch
    func searchForShop(query: String) async throws -> [MKMapItem] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        
        // Filter explicitly for coffee and bakery if possible by query or post-filtering
        // MKLocalSearch.Request doesn't have a strict category filter array, 
        // but we can prioritize the user's query logic.
        // In a real app, we might want to bound this by region (searchRegion).
        
        let search = MKLocalSearch(request: request)
        let response = try await search.start()
        
        let filteredItems = response.mapItems.filter { item in
            guard let category = item.pointOfInterestCategory else { return false }
            return category == .cafe || category == .bakery || category == .restaurant
        }
        
        return filteredItems
    }
    
    // Save a selected MapItem to Firestore if it doesn't exist
    func saveShopToDatabase(mapItem: MKMapItem) async throws -> String {
        guard let name = mapItem.name,
              let coordinate = mapItem.placemark.location?.coordinate else {
            throw NSError(domain: "ShopDiscoveryManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid MapItem"])
        }
        
        // 1. Check for duplicates (Fuzzy match within ~20m)
        // Note: Firestore GeoQueries require a library or geohashing. 
        // For this snippet, we'll assume a simplified check or that we rely on an external GeoFire library/implementation.
        // Alternatively, we can query by exact name + lat/long bounds if traffic is low.
        // Here is a placeholder for the logic described:
        
        let alreadyExists = try await checkIfExists(coordinate: coordinate)
        if let existingID = alreadyExists {
            return existingID
        }
        
        // 2. Convert to Shop Model
        let address = getFormattedAddress(from: mapItem.placemark)
        let newShop = Shop(name: name, address: address, coordinate: coordinate)
        
        // 3. Write to Firestore
        try db.collection("shops").document(newShop.id).setData(from: newShop)
        
        return newShop.id
    }
    
    private func checkIfExists(coordinate: CLLocationCoordinate2D) async throws -> String? {
        // IMPLEMENTATION NOTE:
        // Real geo-queries on Firestore require specific indexing or Geohashes.
        // For MVP/Prototype, we might just query by name and check distance on the client 
        // if the dataset is small, OR use Geohash.
        // Returning nil means "Not found, safe to create".
        return nil
    }
    
    private func getFormattedAddress(from placemark: MKPlacemark) -> String {
        let lines = [
            placemark.subThoroughfare,
            placemark.thoroughfare,
            placemark.locality,
            placemark.administrativeArea,
            placemark.postalCode
        ]
        return lines.compactMap { $0 }.joined(separator: " ")
    }
}


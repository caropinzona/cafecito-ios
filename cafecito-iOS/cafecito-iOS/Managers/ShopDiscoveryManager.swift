import Foundation
import MapKit
import FirebaseFirestore

class ShopDiscoveryManager: NSObject, ObservableObject {
    private let db = Firestore.firestore()
    @Published var savedShops: [Shop] = []
    private var listener: ListenerRegistration?
    
    override init() {
        super.init()
        listenToShops()
    }
    
    deinit {
        listener?.remove()
    }
    
    // Listen for realtime updates from Firestore
    func listenToShops() {
        listener = db.collection("shops").addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            guard let snapshot = snapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            self.savedShops = snapshot.documents.compactMap { document in
                try? document.data(as: Shop.self)
            }
        }
    }
    
    // Search for coffee shops using Apple's MKLocalSearch
    func searchForShop(query: String) async throws -> [MKMapItem] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        
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
        
        // 1. Check for duplicates
        if let existingID = checkLocalDuplicate(coordinate: coordinate) {
            return existingID
        }
        
        // 2. Convert to Shop Model
        let address = getFormattedAddress(from: mapItem.placemark)
        let newShop = Shop(name: name, address: address, coordinate: coordinate)
        
        // 3. Write to Firestore
        try db.collection("shops").document(newShop.id).setData(from: newShop)
        
        return newShop.id
    }
    
    // Check if we already have this shop in our local list (simple distance check)
    private func checkLocalDuplicate(coordinate: CLLocationCoordinate2D) -> String? {
        for shop in savedShops {
            let shopLoc = CLLocation(latitude: shop.coordinates.latitude, longitude: shop.coordinates.longitude)
            let newLoc = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
            // If within 20 meters, consider it the same shop
            if shopLoc.distance(from: newLoc) < 20 {
                return shop.id
            }
        }
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

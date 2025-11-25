import Foundation
import FirebaseFirestore
import CoreLocation

struct Shop: Codable, Identifiable {
    let id: String
    let name: String
    let address: String
    // GeoPoint is a Firestore type. Using a custom Codable strategy or standard Firestore decoding is expected.
    // We use a custom struct or Firestore's GeoPoint if the SDK is available. 
    // For portability in this snippet, I'll use a wrapper that maps to Firestore's structure.
    let coordinates: GeoPoint
    var aggregates: Aggregates
    
    struct Aggregates: Codable {
        var globalRating: Float
        var count: Int
        var brewRatings: [String: Float] // Key: BrewMethod.rawValue
        var vibeRatings: [String: Float] // Key: VibeTag
    }
}

// Extension to help with initialization
extension Shop {
    init(name: String, address: String, coordinate: CLLocationCoordinate2D) {
        self.id = UUID().uuidString
        self.name = name
        self.address = address
        self.coordinates = GeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
        self.aggregates = Aggregates(
            globalRating: 0.0,
            count: 0,
            brewRatings: [:],
            vibeRatings: [:]
        )
    }
}


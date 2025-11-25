import Foundation
import FirebaseFirestore

struct Review: Codable, Identifiable {
    let id: String
    let shopID: String
    let userID: String
    let timestamp: Date
    let ratingData: RatingData
    
    struct RatingData: Codable {
        let coffeeScore: Int // 1-5
        let brewMethod: BrewMethod
        let vibeTags: [String]
    }
}

enum BrewMethod: String, Codable, CaseIterable {
    case espresso = "Espresso"
    case pourOver = "Pour Over"
    case nitro = "Nitro"
    case coldBrew = "Cold Brew"
    case aeropress = "Aeropress"
    case drip = "Drip"
    case other = "Other"
}


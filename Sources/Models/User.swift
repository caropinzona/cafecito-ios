import Foundation

struct User: Codable, Identifiable {
    let id: String
    let email: String?
    var isGhostMode: Bool
    var badges: [String]
    let dateJoined: Date
}


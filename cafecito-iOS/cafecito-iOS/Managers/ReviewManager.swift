import Foundation
import FirebaseFirestore

class ReviewManager: ObservableObject {
    private let db = Firestore.firestore()
    
    func submitReview(shopID: String, rating: Int, brewMethod: BrewMethod, vibeTags: [String]) async throws {
        let reviewID = UUID().uuidString
        // Placeholder user ID until Auth is fully implemented
        let userID = "anonymous_user"
        
        let review = Review(
            id: reviewID,
            shopID: shopID,
            userID: userID,
            timestamp: Date(),
            ratingData: Review.RatingData(
                coffeeScore: rating,
                brewMethod: brewMethod,
                vibeTags: vibeTags
            )
        )
        
        let shopRef = db.collection("shops").document(shopID)
        let reviewRef = db.collection("reviews").document(reviewID)
        
        // Run Transaction to update aggregates atomically
        _ = try await db.runTransaction({ (transaction, errorPointer) -> Any? in
            let shopSnapshot: DocumentSnapshot
            do {
                shopSnapshot = try transaction.getDocument(shopRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard var shop = try? shopSnapshot.data(as: Shop.self) else {
                let error = NSError(domain: "ReviewManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Shop not found"])
                errorPointer?.pointee = error
                return nil
            }
            
            // Calculate new aggregates
            var aggs = shop.aggregates
            
            // 1. Update Global Rating (Weighted Average)
            let oldTotalScore = aggs.globalRating * Float(aggs.count)
            let newCount = aggs.count + 1
            let newGlobalRating = (oldTotalScore + Float(rating)) / Float(newCount)
            
            aggs.globalRating = newGlobalRating
            aggs.count = newCount
            
            // 2. Update Brew Method Rating
            // Simple moving average for MVP since we don't track counts per method yet
            let methodKey = brewMethod.rawValue
            if let oldMethodRating = aggs.brewRatings[methodKey] {
                aggs.brewRatings[methodKey] = (oldMethodRating + Float(rating)) / 2.0
            } else {
                aggs.brewRatings[methodKey] = Float(rating)
            }
            
            // 3. Update Vibe Tags (Frequency count could go here, skipping for now)
            
            shop.aggregates = aggs
            
            // Commit Writes
            do {
                try transaction.setData(from: review, forDocument: reviewRef)
                try transaction.setData(from: shop, forDocument: shopRef)
            } catch let writeError as NSError {
                errorPointer?.pointee = writeError
                return nil
            }
            
            return nil
        })
    }
}


import SwiftUI
import FirebaseFirestore

struct ShopDetailView: View {
    let shopID: String
    @State private var shop: Shop?
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView()
                    .padding(.top, 50)
            } else if let error = errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
                    .padding()
            } else if let shop = shop {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    Text(shop.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                        Text(shop.address)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    // Ratings Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Coffee Rating")
                            .font(.headline)
                        
                        HStack(alignment: .lastTextBaseline) {
                            Text(String(format: "%.1f", shop.aggregates.globalRating))
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.brown)
                            
                            Text("/ 5.0")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("(\(shop.aggregates.count) reviews)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.brown.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Brew Method Breakdown
                    if !shop.aggregates.brewRatings.isEmpty {
                        Text("Brew Methods")
                            .font(.headline)
                            .padding(.top)
                        
                        ForEach(shop.aggregates.brewRatings.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                            HStack {
                                Text(key)
                                Spacer()
                                Text(String(format: "%.1f", value))
                                    .fontWeight(.bold)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    
                    Spacer()
                    
                    // Call to Action
                    Button(action: {
                        // TODO: Open Review Form
                    }) {
                        Label("Rate this Coffee", systemImage: "star.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.brown)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await fetchShopDetails()
        }
    }
    
    private func fetchShopDetails() {
        Task {
            do {
                let doc = try await Firestore.firestore().collection("shops").document(shopID).getDocument()
                if let fetchedShop = try? doc.data(as: Shop.self) {
                    self.shop = fetchedShop
                } else {
                    self.errorMessage = "Shop not found"
                }
                self.isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}


import SwiftUI

struct ShopListView: View {
    @ObservedObject var shopDiscovery: ShopDiscoveryManager
    
    var body: some View {
        NavigationView {
            List(shopDiscovery.savedShops) { shop in
                NavigationLink(destination: ShopDetailView(shopID: shop.id)) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(shop.name)
                                .font(.headline)
                            Text(shop.address)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if shop.aggregates.count > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.brown)
                                    .font(.caption)
                                Text(String(format: "%.1f", shop.aggregates.globalRating))
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Nearby Shops")
        }
    }
}


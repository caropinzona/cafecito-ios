import SwiftUI
import FirebaseFirestore

struct ShopDetailView: View {
    let shopID: String
    @State private var shop: Shop?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var isShowingRateSheet = false
    
    // Custom Colors
    let coffeeDark = Color(red: 0.3, green: 0.2, blue: 0.15)
    let coffeeCream = Color(red: 0.96, green: 0.93, blue: 0.88)
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background
            coffeeCream.opacity(0.3).ignoresSafeArea()
            
            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = errorMessage {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text(error)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            } else if let shop = shop {
                ScrollView {
                    VStack(spacing: 0) {
                        // Hero Header
                        ZStack(alignment: .bottomLeading) {
                            LinearGradient(
                                colors: [coffeeDark, coffeeDark.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .frame(height: 220)
                            
                            // Pattern/Icon overlay
                            Image(systemName: "cup.and.saucer.fill")
                                .font(.system(size: 120))
                                .foregroundColor(.white.opacity(0.1))
                                .offset(x: 200, y: 20)
                                .rotationEffect(.degrees(-15))
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(shop.name)
                                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                                    .foregroundColor(.white)
                                    .shadow(radius: 2)
                                
                                HStack {
                                    Image(systemName: "mappin.circle.fill")
                                    Text(shop.address)
                                        .lineLimit(1)
                                }
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                            }
                            .padding(24)
                        }
                        
                        VStack(spacing: 24) {
                            // Rating Card
                            HStack(spacing: 20) {
                                VStack {
                                    Text(String(format: "%.1f", shop.aggregates.globalRating))
                                        .font(.system(size: 44, weight: .black, design: .rounded))
                                        .foregroundColor(coffeeDark)
                                    
                                    HStack(spacing: 2) {
                                        ForEach(1...5, id: \.self) { star in
                                            Image(systemName: "star.fill")
                                                .font(.caption2)
                                                .foregroundColor(star <= Int(shop.aggregates.globalRating.rounded()) ? .orange : .gray.opacity(0.3))
                                        }
                                    }
                                    
                                    Text("\(shop.aggregates.count) reviews")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.top, 2)
                                }
                                .frame(width: 120)
                                
                                Divider()
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Highlights")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                    
                                    if let topMethod = shop.aggregates.brewRatings.max(by: { $0.value < $1.value })?.key {
                                        HStack {
                                            Image(systemName: "flame.fill")
                                                .foregroundColor(.orange)
                                            Text("Best for: \(topMethod)")
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                        }
                                    } else {
                                        Text("No ratings yet")
                                            .font(.subheadline)
                                            .italic()
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(20)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                            .offset(y: -30) // Overlap effect
                            
                            // Brew Methods Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Brew Methods")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(coffeeDark)
                                    .padding(.horizontal)
                                
                                if shop.aggregates.brewRatings.isEmpty {
                                    Text("No brew methods rated yet.")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal)
                                } else {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(shop.aggregates.brewRatings.sorted(by: { $0.value > $1.value }), id: \.key) { key, value in
                                                VStack(alignment: .leading) {
                                                    Text(key)
                                                        .font(.headline)
                                                        .foregroundColor(coffeeDark)
                                                    
                                                    HStack {
                                                        Image(systemName: "star.fill")
                                                            .font(.caption2)
                                                            .foregroundColor(.orange)
                                                        Text(String(format: "%.1f", value))
                                                            .font(.subheadline)
                                                            .fontWeight(.bold)
                                                            .foregroundColor(.secondary)
                                                    }
                                                }
                                                .padding(12)
                                                .background(Color.white)
                                                .cornerRadius(12)
                                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                            
                            Spacer(minLength: 100) // Space for FAB
                        }
                    }
                }
                .edgesIgnoringSafeArea(.top)
                
                // Floating Action Button
                Button(action: {
                    isShowingRateSheet = true
                }) {
                    HStack {
                        Image(systemName: "plus.bubble.fill")
                        Text("Rate this Coffee")
                            .fontWeight(.bold)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(coffeeDark)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(radius: 5)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
            }
        }
        .task {
            await fetchShopDetails()
        }
        .sheet(isPresented: $isShowingRateSheet) {
            RateCoffeeView(shopID: shopID, isPresented: $isShowingRateSheet) {
                Task {
                    await fetchShopDetails()
                }
            }
            .presentationDetents([.medium, .large])
        }
    }
    
    private func fetchShopDetails() async {
        // Keep existing logic
        do {
            let doc = try await Firestore.firestore().collection("shops").document(shopID).getDocument()
            if doc.exists {
                if let fetchedShop = try? doc.data(as: Shop.self) {
                    self.shop = fetchedShop
                }
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

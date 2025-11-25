import SwiftUI
import FirebaseFirestore

struct ShopDetailView: View {
    let shopID: String
    @State private var shop: Shop?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var isShowingRateSheet = false
    
    // Design Constants
    private let headerHeight: CGFloat = 300
    private let primaryColor = Color(red: 0.1, green: 0.1, blue: 0.1) // Almost black
    private let secondaryColor = Color.gray
    private let accentColor = Color.orange
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background
            Color.white.ignoresSafeArea()
            
            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
            } else if let shop = shop {
                ScrollView {
                    VStack(spacing: 0) {
                        // 1. Header Image
                        GeometryReader { geometry in
                            let minY = geometry.frame(in: .global).minY
                            ZStack {
                                Color(red: 0.3, green: 0.2, blue: 0.15) // Fallback color
                                
                                // Placeholder Pattern since we don't have photos yet
                                Image(systemName: "cup.and.saucer.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 120)
                                    .foregroundColor(.white.opacity(0.1))
                            }
                            .frame(width: geometry.size.width, height: geometry.size.height + (minY > 0 ? minY : 0))
                            .offset(y: minY > 0 ? -minY : 0)
                        }
                        .frame(height: headerHeight)
                        
                        // Main Content
                        VStack(alignment: .leading, spacing: 24) {
                            
                            // 2 & 3. Name and Ratings Header
                            HStack(alignment: .top, spacing: 16) {
                                // Name (Left)
                                Text(shop.name)
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(primaryColor)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                // Ratings (Right)
                                VStack(alignment: .trailing, spacing: 8) {
                                    // Prominent Coffee Rating
                                    HStack(spacing: 4) {
                                        Text(String(format: "%.1f", shop.aggregates.globalRating))
                                            .font(.system(size: 22, weight: .black))
                                        Image(systemName: "star.fill")
                                            .font(.caption)
                                    }
                                    .foregroundColor(primaryColor)
                                    
                                    // Smaller Ratings (Pastries/Amenities placeholders)
                                    HStack(spacing: 12) {
                                        // Amenities Score (Derived from Vibe avg for now)
                                        HStack(spacing: 2) {
                                            Image(systemName: "wifi")
                                            Text("4.8")
                                        }
                                        
                                        // Pastries Score (Placeholder)
                                        HStack(spacing: 2) {
                                            Image(systemName: "birthday.cake")
                                            Text("N/A")
                                        }
                                    }
                                    .font(.caption)
                                    .foregroundColor(secondaryColor)
                                }
                            }
                            
                            // 4. Chips (Amenities)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    // "Open Now" Placeholder
                                    StatusChip(text: "Open Now", icon: "clock.fill", isActive: true)
                                    
                                    // Wifi (Check if "Wifi" is in vibeRatings)
                                    if shop.aggregates.vibeRatings.keys.contains(where: { $0.contains("Wifi") }) {
                                        StatusChip(text: "Wifi", icon: "wifi", isActive: false)
                                    }
                                    
                                    // Seating
                                    StatusChip(text: "Seating", icon: "chair.lounge.fill", isActive: false)
                                }
                            }
                            
                            Divider()
                            
                            // 5. Opening Hours (Placeholder)
                            HStack(alignment: .top) {
                                Image(systemName: "clock")
                                    .foregroundColor(secondaryColor)
                                VStack(alignment: .leading) {
                                    Text("Open Today")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text("07:00 AM - 06:00 PM")
                                        .font(.caption)
                                        .foregroundColor(secondaryColor)
                                }
                            }
                            
                            Divider()
                            
                            // 6. Brew Type Ratings
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Brew Breakdown")
                                    .font(.headline)
                                
                                if shop.aggregates.brewRatings.isEmpty {
                                    Text("No ratings yet")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                } else {
                                    ForEach(shop.aggregates.brewRatings.sorted(by: { $0.value > $1.value }), id: \.key) { key, value in
                                        HStack {
                                            Text(key)
                                                .font(.subheadline)
                                            Spacer()
                                            RatingBar(rating: value)
                                            Text(String(format: "%.1f", value))
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .frame(width: 30, alignment: .trailing)
                                        }
                                    }
                                }
                            }
                            
                            Divider()
                            
                            // 7. Amenities/Vibes Ratings
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Vibe Check")
                                    .font(.headline)
                                
                                if shop.aggregates.vibeRatings.isEmpty {
                                    Text("No vibes reported yet")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                } else {
                                    // Simple flow for vibe tags since they aren't 1-5 ratings in our model yet (just presence or basic score)
                                    // Assuming the model has [String: Float] for vibeRatings
                                    FlowLayout(items: Array(shop.aggregates.vibeRatings.keys), spacing: 8) { vibe in
                                        Text(vibe)
                                            .font(.caption)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.gray.opacity(0.1))
                                            .cornerRadius(16)
                                    }
                                }
                            }
                            
                            Spacer(minLength: 100) // Bottom padding for FAB
                        }
                        .padding(24)
                        .background(Color.white)
                        .cornerRadius(24, corners: [.topLeft, .topRight])
                        .offset(y: -30) // Pull up over image
                    }
                }
                .edgesIgnoringSafeArea(.top)
                
                // Floating CTA
                VStack {
                    Spacer()
                    Button(action: {
                        isShowingRateSheet = true
                    }) {
                        Text("Rate this Coffee")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(primaryColor)
                            .cornerRadius(16)
                            .shadow(radius: 10)
                    }
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

// MARK: - Helper Views

struct StatusChip: View {
    let text: String
    let icon: String
    let isActive: Bool
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isActive ? Color.green.opacity(0.1) : Color.gray.opacity(0.05))
        .foregroundColor(isActive ? .green : .primary)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isActive ? Color.green : Color.clear, lineWidth: 1)
        )
        .cornerRadius(20)
    }
}

struct RatingBar: View {
    let rating: Float
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 6)
                
                Capsule()
                    .fill(Color.orange)
                    .frame(width: geometry.size.width * CGFloat(rating / 5.0), height: 6)
            }
        }
        .frame(height: 6)
        .frame(width: 100)
    }
}

// Simple Flow Layout Helper
struct FlowLayout<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let items: Data
    let spacing: CGFloat
    let content: (Data.Element) -> Content
    
    var body: some View {
        // Simplified vertical list for now to avoid complex geometry reader logic in a single file snippet
        // In a real app, use a robust FlowLayout implementation
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: spacing) {
            ForEach(items, id: \.self) { item in
                content(item)
            }
        }
    }
}

// Extension for specific corner radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

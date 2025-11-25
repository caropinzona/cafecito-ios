import SwiftUI
import MapKit
import CoreLocation

struct MapItemWrapper: Identifiable {
    let id = UUID()
    let item: MKMapItem
}

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var shopDiscovery = ShopDiscoveryManager()
    
    // Initial camera position
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var searchText = ""
    @State private var foundItems: [MKMapItem] = []
    
    // Selection state
    @State private var selectedMapItem: MKMapItem?
    @State private var presentedSheetItem: MapItemWrapper?
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack(alignment: .top) {
                Map(position: $cameraPosition, selection: $selectedMapItem) {
                    UserAnnotation()
                    
                    // 1. Existing Shops (Green) - Click to View Details
                    ForEach(shopDiscovery.savedShops) { shop in
                        Annotation(shop.name, coordinate: CLLocationCoordinate2D(latitude: shop.coordinates.latitude, longitude: shop.coordinates.longitude)) {
                            Image(systemName: "cup.and.saucer.fill")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.green) // Green for saved shops
                                .clipShape(Circle())
                                .shadow(radius: 2)
                                .onTapGesture {
                                    // Navigate directly to details
                                    navigationPath.append(shop.id)
                                }
                        }
                    }
                    
                    // 2. Search Results (Brown) - Click to Add
                    ForEach(foundItems, id: \.self) { item in
                        Annotation(item.name ?? "Shop", coordinate: item.placemark.coordinate) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.brown) // Brown for potential new shops
                                .clipShape(Circle())
                                .shadow(radius: 2)
                                .onTapGesture {
                                    selectedMapItem = item
                                }
                        }
                    }
                }
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                }
                .onAppear {
                    locationManager.requestPermission()
                }
                .onChange(of: selectedMapItem) { oldValue, newValue in
                    if let newValue = newValue {
                        presentedSheetItem = MapItemWrapper(item: newValue)
                    }
                }
                .sheet(item: $presentedSheetItem) { wrapper in
                    ShopPreviewView(mapItem: wrapper.item) {
                        addShopToCafecito(wrapper.item)
                    }
                }
                .navigationDestination(for: String.self) { shopID in
                    ShopDetailView(shopID: shopID)
                }
                
                // Simple Search Overlay
                VStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        TextField("Search for coffee...", text: $searchText)
                            .onSubmit {
                                performSearch()
                            }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 2)
                    .padding()
                    
                    Spacer()
                }
            }
        }
    }
    
    func performSearch() {
        Task {
            do {
                foundItems = try await shopDiscovery.searchForShop(query: searchText)
                
                // Zoom to first result if found
                if let first = foundItems.first {
                    withAnimation {
                        cameraPosition = .region(MKCoordinateRegion(
                            center: first.placemark.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                        ))
                    }
                }
            } catch {
                print("Search error: \(error.localizedDescription)")
            }
        }
    }
    
    func addShopToCafecito(_ item: MKMapItem) {
        Task {
            do {
                let shopID = try await shopDiscovery.saveShopToDatabase(mapItem: item)
                print("Successfully added shop with ID: \(shopID)")
                
                // Dismiss sheet
                presentedSheetItem = nil
                selectedMapItem = nil
                
                // Clear search results so we see the new green pin instead
                foundItems = []
                searchText = ""
                
                // Navigate to Detail View
                try await Task.sleep(nanoseconds: 300_000_000) // 0.3s
                navigationPath.append(shopID)
            } catch {
                print("Error adding shop: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    ContentView()
}

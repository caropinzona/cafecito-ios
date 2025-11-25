import SwiftUI
import MapKit

struct HomeMapView: View {
    @ObservedObject var locationManager: LocationManager
    @ObservedObject var shopDiscovery: ShopDiscoveryManager
    @Binding var navigationPath: NavigationPath
    
    // Initial camera position
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var searchText = ""
    @State private var foundItems: [MKMapItem] = []
    
    // Selection state
    @State private var selectedMapItem: MKMapItem?
    @State private var presentedSheetItem: MapItemWrapper?
    
    // Filters
    let filterOptions = ["Open Now", "Pour Over", "Nitro", "Wifi", "Quiet"]
    @State private var selectedFilters: Set<String> = []
    
    var body: some View {
        ZStack(alignment: .top) {
            Map(position: $cameraPosition, selection: $selectedMapItem) {
                UserAnnotation()
                
                // 1. Existing Shops (Green)
                ForEach(shopDiscovery.savedShops) { shop in
                    Annotation(shop.name, coordinate: CLLocationCoordinate2D(latitude: shop.coordinates.latitude, longitude: shop.coordinates.longitude)) {
                        Image(systemName: "cup.and.saucer.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.green)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                            .onTapGesture {
                                navigationPath.append(shop.id)
                            }
                    }
                }
                
                // 2. Search Results (Brown)
                ForEach(foundItems, id: \.self) { item in
                    Annotation(item.name ?? "Shop", coordinate: item.placemark.coordinate) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.brown)
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
            
            // Search & Filters Overlay
            VStack(spacing: 10) {
                // Search Bar
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
                .padding(.horizontal)
                
                // Filter Chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        Button(action: { /* Open advanced filters */ }) {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.gray)
                                .clipShape(Circle())
                        }
                        
                        ForEach(filterOptions, id: \.self) { filter in
                            Button(action: {
                                if selectedFilters.contains(filter) {
                                    selectedFilters.remove(filter)
                                } else {
                                    selectedFilters.insert(filter)
                                }
                            }) {
                                Text(filter)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(selectedFilters.contains(filter) ? Color.brown : Color(.systemBackground))
                                    .foregroundColor(selectedFilters.contains(filter) ? .white : .primary)
                                    .cornerRadius(20)
                                    .shadow(radius: 1)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.top)
        }
    }
    
    func performSearch() {
        Task {
            do {
                foundItems = try await shopDiscovery.searchForShop(query: searchText)
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
                presentedSheetItem = nil
                selectedMapItem = nil
                foundItems = []
                searchText = ""
                try await Task.sleep(nanoseconds: 300_000_000)
                navigationPath.append(shopID)
            } catch {
                print("Error adding shop: \(error.localizedDescription)")
            }
        }
    }
}


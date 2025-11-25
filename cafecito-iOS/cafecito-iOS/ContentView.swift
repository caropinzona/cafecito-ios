import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var shopDiscovery = ShopDiscoveryManager()
    
    // Initial camera position
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var searchText = ""
    @State private var foundItems: [MKMapItem] = []
    
    var body: some View {
        ZStack(alignment: .top) {
            Map(position: $cameraPosition) {
                UserAnnotation()
                
                ForEach(foundItems, id: \.self) { item in
                    Marker(item.name ?? "Shop", coordinate: item.placemark.coordinate)
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }
            .onAppear {
                locationManager.requestPermission()
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
}

#Preview {
    ContentView()
}

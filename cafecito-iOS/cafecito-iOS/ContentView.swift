import SwiftUI

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var shopDiscovery = ShopDiscoveryManager()
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            TabView {
                ShopListView(shopDiscovery: shopDiscovery)
                    .tabItem {
                        Label("List", systemImage: "list.bullet")
                    }
                
                HomeMapView(locationManager: locationManager, shopDiscovery: shopDiscovery, navigationPath: $navigationPath)
                    .tabItem {
                        Label("Map", systemImage: "map.fill")
                    }
                
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.crop.circle")
                    }
            }
            .navigationDestination(for: String.self) { shopID in
                ShopDetailView(shopID: shopID)
            }
        }
    }
}

#Preview {
    ContentView()
}

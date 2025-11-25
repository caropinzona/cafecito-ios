import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Profile")) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        VStack(alignment: .leading) {
                            Text("Coffee Lover")
                                .font(.headline)
                            Text("Joined Nov 2025")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical)
                }
                
                Section(header: Text("Badges")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            BadgeView(icon: "flame.fill", name: "Espresso Explorer")
                            BadgeView(icon: "cup.and.saucer.fill", name: "Regular")
                            BadgeView(icon: "map.fill", name: "Scout")
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Section(header: Text("Activity")) {
                    Text("No reviews yet")
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Settings")) {
                    NavigationLink(destination: Text("Account Settings")) {
                        Label("Account", systemImage: "gear")
                    }
                    NavigationLink(destination: Text("Privacy")) {
                        Label("Privacy", systemImage: "hand.raised")
                    }
                    Button(role: .destructive) {
                        // Sign out action
                    } label: {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}

struct BadgeView: View {
    let icon: String
    let name: String
    
    var body: some View {
        VStack {
            Circle()
                .fill(Color.brown.opacity(0.1))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(.brown)
                )
            Text(name)
                .font(.caption)
                .multilineTextAlignment(.center)
                .frame(width: 80)
        }
    }
}


import SwiftUI
import MapKit

struct ShopPreviewView: View {
    let mapItem: MKMapItem
    let onAdd: () -> Void
    @State private var isAdding = false
    
    var body: some View {
        VStack(spacing: 16) {
            Capsule()
                .fill(Color.gray.opacity(0.5))
                .frame(width: 40, height: 5)
                .padding(.top, 8)
            
            HStack {
                VStack(alignment: .leading) {
                    Text(mapItem.name ?? "Unknown Shop")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(getFormattedAddress(from: mapItem.placemark))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal)
            
            Button(action: {
                isAdding = true
                onAdd()
            }) {
                HStack {
                    if isAdding {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "plus.circle.fill")
                        Text("Add to Cafecito")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(isAdding)
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .presentationDetents([.height(200)])
        .presentationDragIndicator(.visible)
    }
    
    private func getFormattedAddress(from placemark: MKPlacemark) -> String {
        let lines = [
            placemark.thoroughfare,
            placemark.locality,
            placemark.administrativeArea
        ]
        return lines.compactMap { $0 }.joined(separator: ", ")
    }
}


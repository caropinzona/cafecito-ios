import SwiftUI

struct RateCoffeeView: View {
    let shopID: String
    @Binding var isPresented: Bool
    var onReviewSubmitted: () -> Void
    
    @StateObject private var reviewManager = ReviewManager()
    
    // Form State
    @State private var rating: Int = 3
    @State private var selectedBrewMethod: BrewMethod = .espresso
    @State private var selectedVibes: Set<String> = []
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    
    let availableVibes = ["Quiet", "Busy", "Cozy", "Modern", "Fast Wifi", "Good for Work", "Outdoor Seating"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Coffee Rating")) {
                    HStack {
                        Spacer()
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= rating ? "star.fill" : "star")
                                .font(.largeTitle)
                                .foregroundColor(.brown)
                                .onTapGesture {
                                    rating = star
                                }
                        }
                        Spacer()
                    }
                    .padding(.vertical)
                }
                
                Section(header: Text("Brew Method")) {
                    Picker("Method", selection: $selectedBrewMethod) {
                        ForEach(BrewMethod.allCases, id: \.self) { method in
                            Text(method.rawValue).tag(method)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section(header: Text("Vibe (Select all that apply)")) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                        ForEach(availableVibes, id: \.self) { vibe in
                            Button(action: {
                                if selectedVibes.contains(vibe) {
                                    selectedVibes.remove(vibe)
                                } else {
                                    selectedVibes.insert(vibe)
                                }
                            }) {
                                Text(vibe)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(selectedVibes.contains(vibe) ? Color.brown : Color.gray.opacity(0.2))
                                    .foregroundColor(selectedVibes.contains(vibe) ? .white : .primary)
                                    .cornerRadius(20)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.vertical)
                }
                
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    Button(action: submitReview) {
                        HStack {
                            Spacer()
                            if isSubmitting {
                                ProgressView()
                            } else {
                                Text("Submit Review")
                                    .fontWeight(.bold)
                            }
                            Spacer()
                        }
                    }
                    .disabled(isSubmitting)
                    .listRowBackground(Color.brown)
                    .foregroundColor(.white)
                }
            }
            .navigationTitle("Rate Coffee")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    private func submitReview() {
        isSubmitting = true
        errorMessage = nil
        
        Task {
            do {
                try await reviewManager.submitReview(
                    shopID: shopID,
                    rating: rating,
                    brewMethod: selectedBrewMethod,
                    vibeTags: Array(selectedVibes)
                )
                // Success
                isSubmitting = false
                onReviewSubmitted()
                isPresented = false
            } catch {
                isSubmitting = false
                errorMessage = error.localizedDescription
            }
        }
    }
}


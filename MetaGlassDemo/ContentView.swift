import SwiftUI
import MWDATCamera
import MWDATCore

struct ContentView: View {
    // Track the actual state of the connection, not just a boolean
    @State private var connectionState: String = "Unregistered"
    @State private var registrationError: Error? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Meta Glasses Demo")
                .font(.headline)
            
            // Display dynamic state
            if let error = registrationError {
                Text("Error: \(error.localizedDescription)")
                    .foregroundColor(.red)
            } else {
                Text("Status: \(connectionState)")
                    .foregroundColor(connectionState == "Registered" ? .green : .primary)
            }
            
            Button("Register Device") {
                Task {
                    await triggerRegistration()
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(connectionState == "Registered")
        }
        .padding()
        .task {
            // Start listening for state changes as soon as the view appears
            await observeWearableState()
        }
    }
    
    // MARK: - SDK Methods
    
    private func triggerRegistration() async {
        do {
            registrationError = nil
            // This just kicks off the jump to the Meta app
            try await Wearables.shared.startRegistration()
        } catch {
            await MainActor.run {
                self.registrationError = error
            }
        }
    }
    
    private func observeWearableState() async {
        // This is the crucial part: it listens for updates continuously
        for await state in Wearables.shared.registrationStateStream() {
            await MainActor.run {
                // Update your UI based on what the stream reports
                self.connectionState = String(describing: state)
            }
        }
    }
}

#Preview {
    ContentView()
}

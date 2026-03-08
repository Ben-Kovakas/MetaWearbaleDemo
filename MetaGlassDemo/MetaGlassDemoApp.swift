import SwiftUI
import MWDATCore // Import the core module

@main
struct MetaGlassDemoApp: App {
    
    // --- STEP 3: Initialize the SDK ---
    init () {
        do {
            try Wearables.configure()
        } catch {
            NSLog("dat shit failed bruh")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                // Completes the Meta AI -> app callback step in registration/permission flows.
                .onOpenURL { url in
                    Task {
                        do {
                            _ = try await Wearables.shared.handleUrl(url)
                        } catch {
                            NSLog("Failed to handle wearables callback URL: \(error.localizedDescription)")
                        }
                    }
                }
        }
    }
}

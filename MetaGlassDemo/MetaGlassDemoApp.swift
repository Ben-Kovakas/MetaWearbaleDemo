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
                // --- STEP 4 (Part 1): Handle the URL Callback ---
                // This replaces the AppDelegate openURL method for the "handshake"
                
        }
    }
}

//
//  ContentView.swift
//  MetaGlassDemo
//
//  Created by James Benjamin Kovakas Jr on 2/23/26.
//

import SwiftUI
import MWDATCamera
import MWDATCore

struct ContentView: View {
    @State private var wearableInitialized: Bool = false
//    @State private var wearable:
    @State private var wearableInitializationError: Error? = nil
    
    var body: some View {
        VStack {
            if wearableInitialized {
                Text("Wearable initialized ✅")
            } else if let error = wearableInitializationError {
                Text(verbatim: "Oh no, an error occured during initialization: \(String(describing: error))")
            } else {
                Text("Awaiting wearable initialization...")
            }
        }
        .padding()
        .task {
            do {
                let success = try await initializeWearableDevice()
                await MainActor.run {
                    self.wearableInitialized = success
                    self.wearableInitializationError = nil
                }
            } catch {
                await MainActor.run {
                    self.wearableInitialized = false
                    self.wearableInitializationError = error
                }
            }
        }
    }
    
    func initializeWearableDevice() async throws -> Bool {
        try configureWearables() // configure wearable
        try await startRegistration() // register device
        return true
    }
    
    func deinitWearableDevice() async throws -> Bool {
        try await startUnregistration()
        return true
    }
    
    private func configureWearables() throws(WearableError) {
      do {
        try Wearables.configure()
      } catch {
          throw .configurationFailed(error)
      }
    }
    
    
    func startRegistration() async throws {
      try await Wearables.shared.startRegistration()
    }

    func startUnregistration() async throws {
      try await Wearables.shared.startUnregistration()
    }

    func handleWearablesCallback(url: URL) async throws {
      _ = try await Wearables.shared.handleUrl(url)
    }
}

enum WearableError: Error {
    case configurationFailed(_ error: Error?)
}

#Preview {
    ContentView()
}


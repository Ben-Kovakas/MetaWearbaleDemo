import SwiftUI
import MWDATCamera
import MWDATCore
import UIKit

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    
    // MARK: - UI State
    
    @State private var registrationState: RegistrationState = .unavailable
    @State private var connectionState: String = "Unregistered"
    @State private var registrationErrorMessage: String? = nil
    @State private var cameraPermissionStatus: PermissionStatus? = nil
    @State private var cameraPermissionState: String = "Unknown"
    @State private var streamSession: StreamSession? = nil
    @State private var streamStateText: String = "Stopped"
    @State private var streamErrorMessage: String? = nil
    @State private var latestFrameImage: UIImage? = nil
    @State private var stateListenerToken: AnyListenerToken? = nil
    @State private var frameListenerToken: AnyListenerToken? = nil
    @State private var errorListenerToken: AnyListenerToken? = nil
    
    // MARK: - View
    
    var body: some View {
        VStack(spacing: 20) {
            headerSection
            registrationSection
            permissionSection
            streamControlsSection
            streamStatusSection
            previewSection
        }
        .padding()
        .task {
            await observeWearableState()
        }
        .onDisappear {
            stopCameraStreamOnTask()
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else {
                stopCameraStreamOnTask()
                return
            }
            checkCameraPermissionOnTask()
        }
    }
    
    // MARK: - UI Sections
    
    private var headerSection: some View {
        Text("Meta Glasses Demo")
            .font(.headline)
    }
    
    private var registrationSection: some View {
        Group {
            if let message = registrationErrorMessage {
                Text("Error: \(message)")
                    .foregroundColor(.red)
            } else {
                Text("Status: \(connectionState)")
                    .foregroundColor(registrationState == .registered ? .green : .primary)
            }
            
            Button("Register Device", action: triggerRegistrationOnTask)
                .buttonStyle(.borderedProminent)
                .disabled(registrationState == .registered)
        }
    }
    
    private var permissionSection: some View {
        Group {
            Text("Camera permission: \(cameraPermissionState)")
                .font(.subheadline)
            
            HStack {
                Button("Check Camera Permission", action: checkCameraPermissionOnTask)
                Button("Request Camera Permission", action: requestCameraPermissionOnTask)
            }
        }
    }
    
    private var streamControlsSection: some View {
        Group {
            HStack {
                Button("Start Stream", action: startCameraStreamOnTask)
                    .buttonStyle(.borderedProminent)
                    .disabled(streamSession != nil)
                
                Button("Stop Stream", action: stopCameraStreamOnTask)
                    .buttonStyle(.bordered)
                    .disabled(streamSession == nil)
            }
            
            if let startStreamBlockedReason {
                Text("Can't start stream: \(startStreamBlockedReason)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var streamStatusSection: some View {
        Group {
            Text("Stream: \(streamStateText)")
                .font(.subheadline)
            
            if let streamErrorMessage {
                Text("Stream error: \(streamErrorMessage)")
                    .foregroundColor(.red)
            }
        }
    }
    
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Live Camera Preview")
                .font(.subheadline.weight(.semibold))
            
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
                
                if let latestFrameImage {
                    Image(uiImage: latestFrameImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Text("No frame received yet")
                        .foregroundStyle(.secondary)
                        .font(.footnote)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.secondary.opacity(0.4), lineWidth: 1)
            )
            .frame(maxWidth: .infinity)
            .frame(height: 180)
        }
    }
    
    // MARK: - Task Action Helpers
    
    private func triggerRegistrationOnTask() {
        Task { await triggerRegistration() }
    }
    
    private func checkCameraPermissionOnTask() {
        Task { await checkCameraPermission() }
    }
    
    private func requestCameraPermissionOnTask() {
        Task { await requestCameraPermission() }
    }
    
    private func startCameraStreamOnTask() {
        Task { await startCameraStream() }
    }
    
    private func stopCameraStreamOnTask() {
        Task { await stopCameraStream() }
    }
    
    // MARK: - Registration
    
    private func triggerRegistration() async {
        if registrationState == .registered {
            await MainActor.run { registrationErrorMessage = nil }
            return
        }
        
        do {
            await MainActor.run {
                registrationErrorMessage = nil
                connectionState = "Starting registration..."
            }
            // This kicks off the jump to the Meta AI app.
            try await Wearables.shared.startRegistration()
        } catch let registrationError {
            NSLog("Error during registration: \(registrationError)")
            await MainActor.run {
                switch registrationError {
                case .alreadyRegistered:
                    registrationState = .registered
                    connectionState = "Registered (already connected)"
                    registrationErrorMessage = nil
                case .metaAINotInstalled:
                    registrationErrorMessage = "Meta AI app is not installed or not reachable."
                case .configurationInvalid:
                    registrationErrorMessage = "App configuration is invalid. Check Info.plist MWDAT values."
                case .networkUnavailable:
                    registrationErrorMessage = "Network unavailable. Registration requires internet access."
                default:
                    registrationErrorMessage = "Registration failed: \(registrationError.localizedDescription)"
                }
            }
        }
    }
    
    private func observeWearableState() async {
        for await state in Wearables.shared.registrationStateStream() {
            await MainActor.run {
                registrationState = state
                connectionState = mapRegistrationState(state)
                if state == .registered {
                    registrationErrorMessage = nil
                } else {
                    cameraPermissionStatus = nil
                    cameraPermissionState = "Unavailable (app not fully registered)"
                }
            }
            if state == .registered {
                await checkCameraPermission()
            }
        }
    }
    
    // MARK: - Permissions
    
    private func checkCameraPermission() async {
        await handleCameraPermissionResult {
            try await Wearables.shared.checkPermissionStatus(.camera)
        }
    }
    
    private func requestCameraPermission() async {
        await handleCameraPermissionResult {
            try await Wearables.shared.requestPermission(.camera)
        }
    }
    
    private func handleCameraPermissionResult(
        _ operation: () async throws -> PermissionStatus
    ) async {
        do {
            let status = try await operation()
            await MainActor.run {
                cameraPermissionStatus = status
                cameraPermissionState = mapPermissionState(status)
                registrationErrorMessage = nil
            }
        } catch let permissionError as PermissionError {
            await MainActor.run {
                cameraPermissionStatus = .denied
                cameraPermissionState = unavailableStateFromPermissionError(permissionError)
                registrationErrorMessage = mapPermissionError(permissionError)
            }
        } catch {
            await MainActor.run {
                cameraPermissionStatus = nil
                cameraPermissionState = "Unknown"
                registrationErrorMessage = error.localizedDescription
            }
        }
    }
    
    // MARK: - Streaming
    
    private var canStartStream: Bool {
        startStreamBlockedReason == nil
    }
    
    private var startStreamBlockedReason: String? {
        if registrationState != .registered {
            return "Device is not registered yet."
        }
        if cameraPermissionStatus != .granted {
            return "Camera permission is '\(cameraPermissionState)'."
        }
        if streamSession != nil {
            return "A stream session is already active."
        }
        return nil
    }
    
    private func startCameraStream() async {
        NSLog("Start stream requested")
        guard canStartStream else {
            let reason = startStreamBlockedReason ?? "Unknown start precondition failure."
            await MainActor.run {
                streamStateText = "Start blocked"
                streamErrorMessage = reason
            }
            NSLog("Start stream blocked: \(reason)")
            return
        }
        
        await MainActor.run {
            streamErrorMessage = nil
            streamStateText = "Starting"
        }
        
        let deviceSelector = AutoDeviceSelector(wearables: Wearables.shared)
        let config = StreamSessionConfig(
            videoCodec: .raw,
            resolution: .high,
            frameRate: 7
        )
        let session = StreamSession(streamSessionConfig: config, deviceSelector: deviceSelector)
        
        let newStateToken = session.statePublisher.listen { state in
            Task { @MainActor in
                streamStateText = mapStreamState(state)
            }
        }
        
        let newFrameToken = session.videoFramePublisher.listen { frame in
            guard let image = frame.makeUIImage() else { return }
            Task { @MainActor in
                latestFrameImage = image
            }
        }
        
        let newErrorToken = session.errorPublisher.listen { error in
            Task { @MainActor in
                streamErrorMessage = error.localizedDescription
            }
        }
        
        await MainActor.run {
            stateListenerToken = newStateToken
            frameListenerToken = newFrameToken
            errorListenerToken = newErrorToken
            streamSession = session
        }
        
        await session.start()
    }
    
    private func stopCameraStream() async {
        guard let activeSession = streamSession else { return }
        await activeSession.stop()
        if let token = stateListenerToken { await token.cancel() }
        if let token = frameListenerToken { await token.cancel() }
        if let token = errorListenerToken { await token.cancel() }
        await MainActor.run {
            streamSession = nil
            stateListenerToken = nil
            frameListenerToken = nil
            errorListenerToken = nil
            streamStateText = "Stopped"
            streamErrorMessage = nil
            latestFrameImage = nil
        }
    }
    
    // MARK: - Mappers
    
    private func mapRegistrationState(_ state: RegistrationState) -> String {
        switch state {
        case .unavailable:
            return "Unavailable (0)"
        case .available:
            return "Available (1)"
        case .registering:
            return "Registering (2)"
        case .registered:
            return "Registered (3)"
        }
    }
    
    private func mapPermissionState(_ status: PermissionStatus) -> String {
        switch status {
        case .granted:
            return "Granted"
        case .denied:
            return "Denied"
        @unknown default:
            return "Unknown"
        }
    }
    
    private func mapPermissionError(_ error: Error) -> String {
        if let permissionError = error as? PermissionError {
            switch permissionError {
            case .noDevice:
                return "No compatible device found."
            case .noDeviceWithConnection:
                return "No connected device available."
            case .connectionError:
                return "Connection error while checking permission."
            case .metaAINotInstalled:
                return "Meta AI app is not installed or not reachable."
            case .requestInProgress:
                return "A permission request is already in progress."
            case .requestTimeout:
                return "Permission request timed out."
            case .internalError:
                return "Internal SDK error while checking permission."
            @unknown default:
                return "Permission error: \(permissionError.localizedDescription)"
            }
        }
        return error.localizedDescription
    }
    
    private func mapStreamState(_ state: StreamSessionState) -> String {
        switch state {
        case .stopping:
            return "Stopping"
        case .stopped:
            return "Stopped"
        case .waitingForDevice:
            return "Waiting for device"
        case .starting:
            return "Starting"
        case .streaming:
            return "Streaming"
        case .paused:
            return "Paused"
        @unknown default:
            return "Unknown"
        }
    }
    
    private func unavailableStateFromPermissionError(_ error: PermissionError) -> String {
        switch error {
        case .noDevice, .noDeviceWithConnection, .connectionError:
            return "Unavailable (no connected/eligible device)"
        case .requestInProgress:
            return "Pending (request in progress)"
        case .requestTimeout:
            return "Unknown (request timed out)"
        case .metaAINotInstalled:
            return "Unknown (Meta AI app unavailable)"
        case .internalError:
            return "Unknown (internal error)"
        @unknown default:
            return "Unknown"
        }
    }
}

#Preview {
    ContentView()
}

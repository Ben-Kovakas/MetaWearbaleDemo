# DAT SDK for iOS v0.4

## API Reference

### DecoderError (enum)
Errors that can occur during media decoding operations.

### PhotoCaptureFormat (enum)
Supported formats for capturing photos from Meta Wearables devices.

### StreamSession

A class for managing media streaming sessions with Meta Wearables devices. Handles video streamin...

- start() → Starts video streaming from the device.
- stop() → Stops video streaming and releases all resources.
- capturePhoto(...) → Captures a still photo during streaming.
- streamSessionConfig (property) → The configuration used for this streaming session.
- state (property) → The current state of the streaming session.
- statePublisher (property) → Publisher for streaming session state changes.
- videoFramePublisher (property) → Publisher for video frames received from the streaming session.
- photoDataPublisher (property) → Publisher for photo data captured during the streaming session.
- errorPublisher (property) → Publisher for errors that occur during the streaming session.

### StreamingResolution (enum)
Valid Live Streaming resolutions. We are using 9:16 aspect ratio.

### PhotoData

A photo captured from a Meta Wearables device.

- data (property) → The photo data in the specified format.
- format (property) → The format of the captured photo data.

### StreamSessionConfig

Configuration for a media streaming session with a Meta Wearables device. Defines video codec, re...

- videoCodec (property) → The video codec to use for streaming.
- resolution (property) → The resolution at which to stream video content.
- frameRate (property) → The target frame rate for the streaming session.

### StreamSessionError (enum)
Errors that can occur during streaming sessions.

### StreamSessionState (enum)
Represents the current state of a media streaming session with a Meta Wearables device.

### VideoCodec (enum)
Specifies the video codec to use for streaming.

### VideoFrame

Represents a single frame of video data from a Meta Wearables device. Contains the raw video samp...

- makeUIImage() → Converts the video frame to a UIImage for display or processing. This method handles the conversi...
- sampleBuffer (property) → Provides access to the underlying video sample buffer.

### VideoFrameSize

Represents the width and height of a video frame in pixels.

- width (property) → The width of the video frame in pixels.
- height (property) → The height of the video frame in pixels.

### Announcer

A protocol for objects that can announce events to registered listeners.

- listen(...) → Registers a listener for events of type T.

### AnyListenerToken

A token that can be used to cancel a listener subscription. When the token is no longer reference...

- cancel() → Cancels the listener subscription asynchronously.

### AutoDeviceSelector

A device selector that automatically selects the best available device. Selects the first connect...

- activeDeviceStream() → Creates a stream of active device changes that updates whenever the device list changes.
- activeDevice (property) → The currently active device identifier.

### Device

AI glasses accessible through the Wearables Device Access Toolkit.

- nameOrId() → Returns the device name if available, otherwise returns the device identifier. This provides a fa...
- addLinkStateListener(...) → Adds a listener to receive notifications when the device's link state changes.
- addCompatibilityListener(...) → Adds a listener to receive notifications when the device's compatibility changes.
- deviceType() → Returns the type of this device (e.g., Ray-Ban Meta).
- compatibility() → Returns true if the version of this device is compatible with the Wearables Device Access Toolkit.
- identifier (property) → The unique identifier for this device.
- name (property) → The human-readable device name, or empty string if unavailable.
- linkState (property) → The current connection state of the device.

### DeviceSelector

Protocol for selecting which device should be used for operations. Device selectors determine whi...

- activeDeviceStream() → Creates a stream of active device changes.
- activeDevice (property) → The currently active device identifier, if any.

### DeviceState

Represents the current state of a Meta Wearables device, including battery and hinge information.

- batteryLevel (property) → The current battery level of the device as a percentage (0-100).
- hingeState (property) → The current state of the device's hinge mechanism.

### DeviceStateSession

Manages a session for monitoring device state changes.

- start() → Starts the device state session.
- stop() → Stops the device state session.
- state (property) → The current state of the device session.

### DeviceType (enum)
Represents the types of Meta Wearables devices supported by the Wearables Device Access Toolkit.

### HingeState (enum)
Represents the physical state of the device's hinge mechanism.

### LinkState (enum)
Represents the connection state between a device and the Wearables Device Access Toolkit.

### Mutex

- withLock(...)

### Permission (enum)
Represents the types of permissions that can be requested from AI glasses.

### PermissionError (enum)
Errors that can occur during permission requests.

### PermissionStatus (enum)
Represents the status of a permission request.

### RegistrationError (enum)
Error conditions that can occur during the registration process.

### RegistrationState (enum)
Represents the current state of user registration with the Meta Wearables platform.

### SessionState (enum)
Represents the current state of a device session in the Wearables Device Access Toolkit.

### SpecificDeviceSelector

A device selector that always selects a specific, predetermined device. Use this when you want to...

- activeDeviceStream() → Creates a stream that immediately yields the specific device and then completes.
- activeDevice (property) → The currently active device identifier.

### UnregistrationError (enum)
Error conditions that can occur during the unregistration process.

### Wearables (enum)
The entry point for configuring and accessing the Wearables Device Access Toolkit.

### WearablesError (enum)
Errors that can occur during Device Access Toolkit configuration.

### WearablesHandleURLError (enum)
Errors that can occur during URL handling.

### WearablesInterface

The primary interface for Wearables Device Access Toolkit.

- addRegistrationStateListener(...) → Adds a listener to receive callbacks when the registration state changes. The listener is immedia...
- registrationStateStream() → Creates an <code>AsyncStream</code> for observing registration state changes.
- startRegistration() → Initiates the registration process with AI glasses.
- handleUrl(...) → Handles callback URLs from the Meta AI app during registration and permission flows.
- startUnregistration() → Initiates the unregistration process with AI glasses.
- addDevicesListener(...) → Adds a listener to receive callbacks when the device list changes. The listener is immediately ca...
- devicesStream() → Creates an <code>AsyncStream</code> for observing device list changes.
- deviceForIdentifier(...) → Fetch the underlying [Device](/reference/ios_swift/dat/0.4/mwdatcore_device) object for a given [...
- checkPermissionStatus(...) → Checks if a specific permission is granted for the current application.
- requestPermission(...) → Requests a specific permission on AI glasses.
- addDeviceSessionStateListener(...) → Adds a listener to receive callbacks when the session state changes for a specific device. The li...
- registrationState (property) → The current registration state of the user's devices. See [RegistrationState](/reference/ios_swif...
- devices (property) → The current list of devices available.

### MockDevice

- powerOn() → Powers on the mock device.
- powerOff() → Powers off the mock device.
- don() → Simulates putting on (donning) the device.
- doff() → Simulates taking off (doffing) the device.
- deviceIdentifier (property) → The unique device identifier for this mock device.

### MockCameraKit

A suite for mocking camera functionality.

- setCameraFeed(...) → Sets the camera feed from a video file.
- setCapturedImage(...) → Sets the captured image from an image file.

### MockDeviceKit (enum)
The entry-point to the MockDeviceKit for managing simulated Meta Wearables devices. Use this in t...

### MockDeviceKitError (enum)
Errors that can occur when using MockDeviceKit.

### MockDeviceKitInterface

Interface for managing mock Meta Wearables devices for testing and development.

- pairRaybanMeta() → Pairs a simulated Ray-Ban Meta device.
- unpairDevice(...) → Unpairs a simulated device.
- pairedDevices (property) → The list of all currently paired mock devices.

### MockDisplaylessGlasses

Protocol for simulating displayless smart glasses behavior in testing and development. Provides f...

- fold() → Simulates folding the glasses into a closed position.
- unfold() → Simulates unfolding the glasses into an open position.
- getCameraKit() → Gets the suite for mocking camera functionality.

### MockRaybanMeta

Protocol for simulating Ray-Ban Meta smart glasses behavior in testing and development. Inherits ...

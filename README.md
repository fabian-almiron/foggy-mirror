# Foggy Mirror App 🪞💨

An interactive iPhone app that simulates breathing on a mirror to create fog effects, allowing users to draw on the fogged surface.

## Features

- **Camera Mirror**: Uses the front-facing camera to create a mirror effect
- **Breath Detection**: Uses the microphone to detect breathing sounds and intensity
- **Dynamic Fog Effect**: Creates realistic fog that appears when you breathe on the screen
- **Touch Drawing**: Draw on the fogged mirror surface with your finger
- **Fog Dissipation**: Fog gradually fades away over time for realistic behavior
- **Real-time Feedback**: Visual indicators show when breathing is detected

## How to Use

1. **Launch the App**: Tap "Start Mirror" from the main screen
2. **Position Your Phone**: Hold your iPhone like a mirror in front of your face
3. **Breathe on the Screen**: Breathe onto the phone's microphone to create fog
4. **Draw**: Once fog appears, use your finger to draw on the fogged area
5. **Watch It Fade**: The fog will naturally dissipate over time

## Technical Implementation

### Core Components

- **SwiftUI Interface**: Modern, responsive UI built with SwiftUI (iOS 26 compatible)
- **AVFoundation**: Camera access and audio input processing with proper permission handling
- **Real-time Audio Processing**: Detects breathing through microphone input with RMS calculation
- **Custom Drawing Canvas**: Touch-based drawing with fog interaction using Canvas API
- **Animated Effects**: Smooth fog animations and particle effects optimized for performance

### Key Features

- **Front Camera Mirror**: Horizontally flipped camera view for natural mirror experience
- **Audio Level Detection**: RMS calculation for breath intensity measurement
- **Fog Opacity Control**: Dynamic fog opacity based on breathing intensity
- **Drawing Masking**: Drawing removes fog to reveal the mirror underneath
- **Timer-based Dissipation**: Gradual fog fade-out for realism

## Setup Instructions

### Prerequisites

- Xcode 16.0 or later
- iOS 17.0 or later (compatible up to iOS 26)
- iPhone device (iPhone 11 or newer recommended for best performance)
- **Physical iPhone required** - camera and microphone access needed

### Installation

1. **Open the Project**:
   - Double-click `FoggyMirror.xcodeproj` to open in Xcode
   - Or use: `open FoggyMirror.xcodeproj`

2. **Configure Signing**:
   - In Xcode, select the project in the navigator
   - Go to "Signing & Capabilities" tab
   - Select your Apple Developer account under "Team"
   - Ensure "Automatically manage signing" is checked

3. **Connect Your iPhone**:
   - Connect your iPhone via USB cable
   - Unlock your device and trust the computer if prompted
   - Enable Developer Mode: Settings > Privacy & Security > Developer Mode

4. **Select Your Device**:
   - In Xcode's toolbar, click the device dropdown (next to the play button)
   - Select your connected iPhone from the list
   - ⚠️ **Do NOT use the simulator** - camera and microphone are required

5. **Build and Run**:
   - Press **Cmd+R** or click the **Play button**
   - Xcode will build and install the app on your device
   - Grant camera and microphone permissions when prompted

### Permissions

The app requires the following permissions:
- **Camera Access**: For the mirror effect
- **Microphone Access**: For breath detection

These permissions are automatically requested when the app launches.

## Project Structure

```
FoggyMirror/
├── FoggyMirrorApp.swift      # Main app entry point
├── ContentView.swift         # Welcome screen and navigation
├── MirrorView.swift         # Main mirror interface
├── CameraView.swift         # Camera preview implementation
├── AudioManager.swift       # Microphone and audio processing
├── DrawingCanvas.swift      # Touch drawing and fog effects
├── Assets.xcassets/         # App icons and assets
└── Info.plist              # App configuration and permissions
```

## Customization

### Adjusting Sensitivity

In `AudioManager.swift`, modify the breathing threshold:
```swift
private let breathingThreshold: Float = 0.1  // Adjust this value
```

### Fog Appearance

In `DrawingCanvas.swift`, customize fog colors and effects:
```swift
RadialGradient(
    gradient: Gradient(colors: [
        Color.white.opacity(0.8),    // Center color
        Color.gray.opacity(0.6),     // Middle color
        Color.white.opacity(0.4)     // Edge color
    ]),
    // ... other parameters
)
```

### Drawing Properties

Modify line width and drawing behavior:
```swift
@State private var lineWidth: CGFloat = 20.0  // Adjust drawing thickness
```

## Troubleshooting

### Common Issues

**Build Issues:**
1. **"No Development Team"**: Go to project settings > Signing & Capabilities and select your Apple ID
2. **"Device Not Found"**: Ensure your iPhone is connected, unlocked, and trusted
3. **"Provisioning Profile Error"**: Enable "Automatically manage signing" in project settings
4. **"Unsupported Device"**: App requires iPhone 11 or newer (iOS 26 compatibility)

**Runtime Issues:**
1. **Camera Not Working**: Ensure camera permissions are granted in Settings > Privacy & Security > Camera
2. **No Fog Appearing**: Check microphone permissions and try breathing closer to the device
3. **Drawing Not Working**: Fog opacity must be above 0.2 for drawing to be enabled
4. **App Crashes**: Ensure you're running on a physical device, not simulator
5. **Black Screen**: Check that camera permissions are granted and device camera is working

### Performance Tips

- Close other apps to free up camera and microphone resources
- Ensure good lighting for optimal camera performance
- Keep the microphone unobstructed for best breath detection

## Future Enhancements

Potential features for future versions:
- Different fog patterns and colors
- Save and share drawings
- Multiple drawing tools and brushes
- Sound effects and haptic feedback
- Social sharing capabilities

## License

This project is created for educational and entertainment purposes.

---

Enjoy creating art on your foggy mirror! 🎨✨

# Quick Xcode File Addition Guide

## Files that need to be added to Xcode:

These 6 files are in your main FoggyMirror folder but not yet in the Xcode project:

1. `Animal.swift` - Animal data models
2. `AppState.swift` - App state management  
3. `AnimalSelectionView.swift` - Animal picker screen
4. `FogCanvasView.swift` - Fog and drawing canvas
5. `MicrophoneManager.swift` - Microphone blow detection
6. `WaterDropView.swift` - Water droplet animations

## Quick Steps:

1. In Xcode, right-click the blue "FoggyMirror" folder in left sidebar
2. Choose "Add Files to 'FoggyMirror'"
3. Select all 6 files above (hold Cmd to select multiple)
4. Click "Add"
5. Build with Cmd+R

## If you see the files grayed out:
- They might already be added but not to the target
- Select each file and check "Target Membership" in right sidebar
- Make sure "FoggyMirror" target is checked

Your Magic Mirror app will then build successfully! 🎉

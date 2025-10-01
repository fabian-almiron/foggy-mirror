# Magic Mirror Assets Guide

## Required Images for Magic Mirror App

### Animal Images (300x300px recommended, PNG with transparent background)

1. **bernese_spa.png** 
   - Bernese Mountain Dog in spa setting
   - Should show the dog wearing a bathrobe and shower cap
   - Cute/kawaii style preferred
   - Place in: `Assets.xcassets/bernese_spa.imageset/`

2. **tuxedo_cat_spa.png**
   - Tuxedo Cat in spa setting  
   - Should show the cat with a luxurious towel wrap and cucumber eye mask
   - Cute/kawaii style preferred
   - Place in: `Assets.xcassets/tuxedo_cat_spa.imageset/`

3. **gecko_spa.png**
   - Gecko in spa setting
   - Should show the gecko relaxing with a tiny spa headband and face mask
   - Cute/kawaii style preferred
   - Place in: `Assets.xcassets/gecko_spa.imageset/`

### Mirror Frame Image

4. **ornate_mirror.png** ✅ **ALREADY EXISTS**
   - Your existing ornate mirror frame is perfect!
   - Currently at: `Assets.xcassets/ornate_mirror.imageset/ornate_mirror.png`
   - The app will use this automatically

## How to Add Animal Images to Xcode:

1. Open your `FoggyMirror.xcodeproj` in Xcode
2. In the left sidebar, navigate to `Assets.xcassets`
3. Right-click and select **"New Image Set"**
4. Name it exactly as specified above (e.g., "bernese_spa")
5. Drag your PNG file into the **"1x"** slot
6. The app will automatically use these images

## Current Status:
- ✅ Mirror frame: Already exists as `ornate_mirror.png`
- ❌ Bernese Mountain Dog spa image: NEEDED
- ❌ Tuxedo Cat spa image: NEEDED  
- ❌ Gecko spa image: NEEDED

## Code References:
- Animal images are referenced in `Models/Animal.swift`
- Mirror frame is referenced in `Views/MirrorView.swift`
- Placeholder emojis are currently used until real images are added

## What Happens When You Add Images:
- The app will automatically detect and use your real images
- Placeholder emojis will be replaced with your actual animal photos
- The kawaii spa theme will look amazing with proper images!

## Image Requirements:
- **Format**: PNG with transparent background
- **Size**: 300x300px recommended (any size works)
- **Style**: Cute/kawaii spa theme
- **Content**: Animals wearing spa accessories as described above

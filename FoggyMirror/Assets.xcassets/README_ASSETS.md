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

4. **ornate_mirror_frame.png** (ALREADY EXISTS as ornate_mirror.png)
   - Ornate bathroom mirror frame
   - Decorative, vintage style
   - PNG with transparent center (the mirror area should be transparent)
   - Full screen size or scalable
   - Currently using: `Assets.xcassets/ornate_mirror.imageset/ornate_mirror.png`

## How to Add Images to Xcode:

1. Open your project in Xcode
2. Navigate to `Assets.xcassets` in the project navigator
3. Right-click and select "New Image Set"
4. Name it exactly as specified above (e.g., "bernese_spa")
5. Drag your PNG file into the "1x" slot
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

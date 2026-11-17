# Rivals Boost for iPad

A native SwiftUI companion app for iPad Air players. It provides practical Roblox graphics/performance checklists, selectable guidance presets, original skybox concept previews, and device-generation notes.

## What it does
- Runs as a standalone iPadOS app.
- Provides Low Latency, Balanced, and Visual guidance presets.
- Shows original in-app skybox concept previews.
- Helps users identify their iPad Air generation.
- Separates app-side previews from changes an experience creator can make in Roblox Studio.

## What it does not do
- It does not inject code into Roblox or modify Roblox private app data.
- It does not install FastFlags into the Roblox iPad app.
- It does not bypass anti-cheat or promise an undetectable setup.
- It cannot force a 60+ FPS mode, custom shaders, skyboxes, or textures into a third-party experience.
- It does not guarantee an FPS increase.

## Build with Xcode
1. Install Xcode and XcodeGen.
2. From this directory, run xcodegen generate.
3. Open RivalsBoost.xcodeproj in Xcode.
4. Select an iPad simulator or a connected iPad Air.
5. Set your Apple Developer signing team for device installation.
6. Build and run.

An installable IPA for a physical iPad requires code signing with an Apple development or distribution identity and provisioning profile. The source in this repository is not itself an IPA.

## Device note
The app defaults to an unknown iPad Air generation. Check Settings → General → About → Model Name on the iPad before making device-specific performance assumptions.

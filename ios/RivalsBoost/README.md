# Rivals Boost for iPad

A native SwiftUI companion app for iPad Air players. It provides practical Roblox graphics/performance checklists, selectable guidance presets, a live shader preview studio powered by SwiftUI and Metal, original skybox concept previews, a configurable texture-pattern studio with JSON manifest export, device-generation notes, and a module diagnostics screen.

## Shader Studio
- Three shader-style looks: Neon, Cinematic, and Crisp.
- Live intensity control and an on/off comparison switch.
- A custom Metal color-grading shader rendered by the Rivals Boost app itself.
- Shader source: `Sources/RivalsBoostShaders.metal`.
- SwiftUI controls and preview scene: `Sources/ShaderStudio.swift`.

The Metal effect is real and runs on the app's preview canvas. It is not injected into Roblox and cannot alter the graphics of Roblox Rivals or another third-party game on iPadOS.

## Texture Pack Studio
- Four original pattern previews: Tactical Grid, Carbon, Digital, and Clean.
- Custom pack name, accent palette, and tile-scale controls.
- Exports a versioned JSON design manifest through the iOS share sheet.
- Manifest is a design handoff, not a supported Roblox client texture import format.

## Module diagnostics
- The app links the local `../InjectionLab` Swift package and its `BoostProbe` dynamic-library product.
- The Diagnostics tab calls `BoostProbe.diagnostics()` and `BoostProbe.selfTest()` from the host app.
- Xcode/Swift Package Manager handles normal framework linking, embedding, and signing for this app.
- The module is only loaded by Rivals Boost; it does not attach to or modify other processes.

## What it does
- Runs as a standalone iPadOS app.
- Provides Low Latency, Balanced, and Visual guidance presets.
- Shows original in-app skybox concept previews.
- Helps users identify their iPad Air generation.
- Verifies the app-owned dynamic module through an in-app diagnostics screen.
- Separates app-side previews from changes an experience creator can make in Roblox Studio.

## What it does not do
- It does not inject code into Roblox or modify Roblox private app data.
- It does not install FastFlags into the Roblox iPad app.
- It does not bypass anti-cheat or promise an undetectable setup.
- It cannot force custom shaders, skyboxes, or textures into a third-party experience.
- It does not guarantee an FPS increase or unlock a frame-rate cap.

## Build with Xcode
1. Install Xcode and XcodeGen.
2. From this directory, run `xcodegen generate`.
3. Open `RivalsBoost.xcodeproj` in Xcode.
4. Select an iPad simulator or a connected iPad Air.
5. Set your Apple Developer signing team for device installation.
6. Build and run.

The XcodeGen project references the local Swift package at `../InjectionLab`, so keep both directories in the repository checkout.

An installable IPA for a physical iPad requires code signing with an Apple development or distribution identity and provisioning profile. The source in this repository is not itself an IPA.

## Device note
The app defaults to an unknown iPad Air generation. Check Settings → General → About → Model Name on the iPad before making device-specific performance assumptions.

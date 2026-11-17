# Adrian fflag

A native iOS profile manager for Roblox visual preferences, with a Rivals-focused profile, editable visual presets, and JSON export.

## What this app does
- Saves local visual profiles on-device.
- Provides Competitive, Performance, and Visual starting presets.
- Lets you tune visual preference values and skybox preset metadata.
- Exports a JSON profile for inspection or use by a separately supported workflow.

## Important compatibility note
This app does **not** inject into Roblox, modify the Roblox app bundle, install shaders, replace game textures, or force unsupported FastFlags. iOS apps are sandboxed, and Roblox controls which client configuration options it accepts. A JSON export is a profile document, not proof that Roblox will apply its values.

Custom skyboxes, texture packs, and shaders require Roblox/game-side support. The Rivals profile is a profile organization feature; it does not alter Rivals itself.

## Build
1. Open `Adrian fflag.xcodeproj` in Xcode on macOS.
2. Select the `Adrian fflag` target.
3. Set your own signing team and bundle identifier.
4. Build and run on an iPhone or iPad.

An IPA can only be signed/exported by a suitable Apple development/distribution workflow. This repository contains source, not a pre-signed IPA.

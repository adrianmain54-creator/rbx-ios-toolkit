# Rivals Boost Injection Lab

This lab verifies a **dynamic iOS module in an app you own**. It is deliberately a normal, signed Swift Package dynamic library—not a Roblox patcher, process injector, exploit, or anti-cheat evasion tool.

## What it proves

- The module builds as a dynamic library for iOS 17+.
- A host app can link and embed the module through Xcode/Swift Package Manager.
- The host can call a public API and run a small self-test.
- The module reports basic runtime diagnostics without inspecting other apps.

## Add it to the Rivals Boost host app

1. In Xcode, open the host app project.
2. Choose **File → Add Package Dependencies → Add Local…**
3. Select this `ios/InjectionLab` directory.
4. Add the `BoostProbe` product to the **RivalsBoost app target**.
5. In a host-app Swift file, import and call:

```swift
import BoostProbe

let diagnostics = BoostProbe.diagnostics()
let moduleLoaded = BoostProbe.selfTest()
```

Xcode/SwiftPM handles linking, embedding, and signing as part of the host app's normal build. Do not copy the library into another vendor's app or alter another app's executable.

## Build and test

From this directory on a Mac with Xcode:

```sh
swift test
```

For an iOS simulator build:

```sh
xcodebuild -scheme BoostProbe -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

A physical-device build must be signed by the developer account used to install the host app. This lab makes no claim of being undetectable and does not change Roblox or Rivals behavior.

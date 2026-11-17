import Foundation

/// A harmless module used to verify dynamic-framework integration in an app you own.
/// This does not inspect, modify, or attach to other apps or processes.
public enum BoostProbe {
    public static let moduleName = "RivalsBoost.BoostProbe"

    public static func diagnostics() -> [String: String] {
        [
            "module": moduleName,
            "platform": "iOS",
            "runtime": ProcessInfo.processInfo.operatingSystemVersionString,
            "status": "loaded by the host app's normal signed framework loader"
        ]
    }

    public static func selfTest() -> Bool {
        !moduleName.isEmpty && Bundle(for: ProbeBundleToken.self).bundleIdentifier != nil
    }
}

private final class ProbeBundleToken {}

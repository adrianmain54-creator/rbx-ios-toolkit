// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BoostInjectionLab",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "BoostProbe", type: .dynamic, targets: ["BoostProbe"])
    ],
    targets: [
        .target(name: "BoostProbe"),
        .testTarget(name: "BoostProbeTests", dependencies: ["BoostProbe"])
    ]
)

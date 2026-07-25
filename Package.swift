// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "QuickRNG",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(name: "QuickRNG", path: "Sources/QuickRNG")
    ]
)

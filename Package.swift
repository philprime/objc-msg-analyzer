// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "objc-msg-analyzer",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "objc-msg-analyzer", targets: ["objc-msg-analyzer"])
    ],
    targets: [
        .executableTarget(name: "objc-msg-analyzer")
    ]
)

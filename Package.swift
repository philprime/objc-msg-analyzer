// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "objc-log-analyser",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "objc-log-analyser", targets: ["objc-log-analyser"])
    ],
    targets: [
        .target(name: "objc-log-analyser"),
    ]
)

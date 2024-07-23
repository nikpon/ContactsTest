// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Utilities",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "Utilities", targets: ["Utilities"]),
    ],
    targets: [
        .target(name: "Utilities"),
        .testTarget(name: "UtilitiesTests", dependencies: ["Utilities"]),
    ]
)

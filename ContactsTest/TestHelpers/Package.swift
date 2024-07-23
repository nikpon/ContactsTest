// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TestHelpers",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "Mocking",
            targets: ["Mocking"]),
    ],
    dependencies: [
        .package(name: "Utilities", path: "../Utilities"),
    ],
    targets: [
        .target(
            name: "Mocking", dependencies: ["Utilities"]
        )
    ]
)

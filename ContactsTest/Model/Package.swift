// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Model",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "Persistance", targets: ["Persistance"]),
        .library(name: "SystemContacts", targets: ["SystemContacts"]),
        .library(name: "Models", targets: ["Models"])
    ],
    dependencies: [
        .package(name: "Utilities", path: "../Utilities"),
    ],
    targets: [
        .target(name: "Persistance", dependencies: ["Utilities", "Models"]),
        .target(name: "SystemContacts", dependencies: ["Utilities", "Models"]),
        .target(name: "Models", dependencies: [])
    ]
)

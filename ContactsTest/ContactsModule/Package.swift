// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ContactsModule",  
    defaultLocalization: "en",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "ContactsModule",
            targets: ["ContactsModule"]
        )
    ],
    dependencies: [
        .package(name: "Model", path: "../Model")
    ],
    targets: [
        .target(
            name: "ContactsModule",
            dependencies: [
                .product(name: "Persistance", package: "Model"),
                .product(name: "Models", package: "Model"),
                .product(name: "SystemContacts", package: "Model")
            ]
        ),
        .testTarget(name: "ContactsModuleTests", dependencies: ["ContactsModule"]),
    ]
)

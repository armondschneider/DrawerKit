// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "DrawerKit",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "DrawerKit",
            targets: ["DrawerKit"]
        )
    ],
    dependencies: [
        // Add any external dependencies here (if any)
    ],
    targets: [
        // Define the DrawerKit target with source files
        .target(
            name: "DrawerKit",
            dependencies: [],
            path: "Sources/DrawerKit",
            exclude: ["Resources"]
        ),
        // Define the test target for DrawerKit
        .testTarget(
            name: "DrawerKitTests",
            dependencies: ["DrawerKit"],
            path: "Tests/DrawerKitTests"
        )
    ]
)

// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "DrawerKit",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "DrawerKit",
            targets: ["DrawerKit"]
        )
    ],
    targets: [
        .target(
            name: "DrawerKit",
            path: "Sources/DrawerKit",
            exclude: []
        ),
        .testTarget(
            name: "DrawerKitTests",
            dependencies: ["DrawerKit"],
            path: "Tests/DrawerKitTests"
        )
    ]
)

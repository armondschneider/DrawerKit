// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "DrawerKit",
    platforms: [
        .iOS(.v26),
        .macOS(.v26)
    ],
    products: [
        .library(
            name: "DrawerKit",
            targets: ["DrawerKit"]
        ),
        .executable(
            name: "DrawerKitTests",
            targets: ["DrawerKitTests"]
        )
    ],
    targets: [
        .target(
            name: "DrawerKit",
            path: "Sources/DrawerKit",
            exclude: []
        ),
        .executableTarget(
            name: "DrawerKitTests",
            dependencies: ["DrawerKit"],
            path: "Tests/DrawerKitTests"
        )
    ]
)

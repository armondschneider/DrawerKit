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
        )
    ],
    targets: [
        .target(
            name: "DrawerKit",
            path: "Sources",
            sources: [
                "DrawerKit/Drawer.swift",
                "Examples/DemoView.swift"
            ]
        ),
        .testTarget(
            name: "DrawerKitTests",
            dependencies: ["DrawerKit"],
            path: "Tests/DrawerKitTests"
        )
    ]
)

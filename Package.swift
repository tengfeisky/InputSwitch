// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "InputSwitch",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "InputSwitch", targets: ["InputSwitch"]),
    ],
    targets: [
        .executableTarget(
            name: "InputSwitch",
            dependencies: [],
            resources: [
                .process("Assets.xcassets")
            ],
            swiftSettings: [
                .unsafeFlags(["-framework", "Carbon"])
            ]
        ),
    ]
)

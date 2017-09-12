// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftCLI",
    products: [
        .library(name: "SwiftCLI", targets: ["SwiftCLI"]),
    ],
    targets: [
        .target(name: "SwiftCLI", dependencies: []),
        .testTarget(name: "SwiftCLITests", dependencies: ["SwiftCLI"]),
    ]
)

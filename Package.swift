// swift-tools-version:4.2
// Managed by ice

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

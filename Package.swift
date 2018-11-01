// swift-tools-version:4.0
// Managed by ice

import PackageDescription

let package = Package(
    name: "SwiftCLI",
    products: [
        .library(name: "SwiftCLI", targets: ["SwiftCLI"]),
        .executable(name: "ExampleCLI", targets: ["ExampleCLI"])
    ],
    targets: [
        .target(name: "SwiftCLI", dependencies: []),
        .target(name: "ExampleCLI", dependencies: ["SwiftCLI"]),
        .testTarget(name: "SwiftCLITests", dependencies: ["SwiftCLI"]),
    ]
)

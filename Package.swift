// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "swift-edf",
    products: [
        .library(
            name: "EDF",
            targets: ["EDF"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/p-x9/swift-fileio.git", from: "0.1.0")
    ],
    targets: [
        .target(
            name: "EDF",
            dependencies: [
                "EDFC",
                .product(name: "FileIO", package: "swift-fileio")
            ]
        ),
        .target(
            name: "EDFC"
        ),
        .testTarget(
            name: "EDFTests",
            dependencies: ["EDF"]
        ),
    ]
)

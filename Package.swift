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
    targets: [
        .target(
            name: "EDF",
            dependencies: [
                "EDFC"
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

// swift-tools-version: 6.2

import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("ExistentialAny"),
]

let package = Package(
    name: "LocalPackage",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .library(
            name: "DataSource",
            targets: ["DataSource"]
        ),
        .library(
            name: "Model",
            targets: ["Model"]
        ),
        .library(
            name: "UserInterface",
            targets: ["UserInterface"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", exact: "1.13.2"),
        .package(url: "https://github.com/Kyome22/AllocatedUnfairLock.git", exact: "1.0.0"),
        .package(url: "https://github.com/Kyome22/SpiceKey.git", exact: "5.3.0"),
    ],
    targets: [
        .target(
            name: "DataSource",
            dependencies: [
                .product(name: "AllocatedUnfairLock", package: "AllocatedUnfairLock"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "SpiceKey", package: "SpiceKey"),
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "Model",
            dependencies: [
                "DataSource",
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "UserInterface",
            dependencies: [
                "DataSource",
                "Model",
            ],
            resources: [
                .process("Resources"),
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "DataSourceTests",
            dependencies: [
                "DataSource",
                .product(name: "AllocatedUnfairLock", package: "AllocatedUnfairLock"),
                .product(name: "SpiceKey", package: "SpiceKey"),
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "ModelTests",
            dependencies: [
                "Model",
                .product(name: "AllocatedUnfairLock", package: "AllocatedUnfairLock"),
                .product(name: "SpiceKey", package: "SpiceKey"),
            ],
            swiftSettings: swiftSettings
        ),
    ]
)

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
        .package(url: "https://github.com/apple/swift-async-algorithms.git", exact: "1.1.4"),
        .package(url: "https://github.com/apple/swift-log.git", exact: "1.13.2"),
        .package(url: "https://github.com/Kyome22/AllocatedUnfairLock.git", exact: "1.0.0"),
        .package(url: "https://github.com/Kyome22/DeviceModel.git", exact: "1.2.0"),
        .package(url: "https://github.com/Kyome22/SpiceKey.git", exact: "6.0.1"),
        .package(url: "https://github.com/Kyome22/WindowSceneKit.git", exact: "3.0.0"),
    ],
    targets: [
        .target(
            name: "DataSource",
            dependencies: [
                .product(name: "AllocatedUnfairLock", package: "AllocatedUnfairLock"),
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "SpiceKey", package: "SpiceKey"),
                .product(name: "WindowSceneKit", package: "WindowSceneKit"),
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "Model",
            dependencies: [
                "DataSource",
                .product(name: "DeviceModel", package: "DeviceModel"),
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

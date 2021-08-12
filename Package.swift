// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "covid19-pt-apple-wallet-web",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/ehn-dcc-development/base45-swift", .branch("main")),
        .package(url: "https://github.com/tsolomko/SWCompression.git", from: "4.6.0"),
        .package(url: "https://github.com/unrelentingtech/SwiftCBOR.git", .branch("master")),
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "base45-swift", package: "base45-swift"),
                .product(name: "SWCompression", package: "SWCompression"),
                .product(name: "SwiftCBOR", package: "SwiftCBOR"),
            ],
            swiftSettings: [
                // Enable better optimizations when building in Release configuration. Despite the use of
                // the `.unsafeFlags` construct required by SwiftPM, this flag is recommended for Release
                // builds. See <https://github.com/swift-server/guides/blob/main/docs/building.md#building-for-production> for details.
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ]
        ),
        .target(name: "Run", dependencies: [.target(name: "App")]),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)

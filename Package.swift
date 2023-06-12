// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "swift-http",
    platforms: [
        .macOS(.v12),
        .iOS(.v15),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(name: "SwiftHttp", targets: ["SwiftHttp"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log", from: "1.5.0"),
    ],
    targets: [
        .target(name: "SwiftHttp", dependencies: [
            .product(name: "Logging", package: "swift-log")
        ]),
        .testTarget(name: "SwiftHttpTests", dependencies: ["SwiftHttp"]),
    ]
)

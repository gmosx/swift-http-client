// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "HTTPClient",
    products: [
        .library(name: "HTTPClient", targets: ["HTTPClient"])
    ],
    dependencies: [
        .package(url: "https://github.com/IBM-Swift/LoggerAPI.git", from: "1.0.0"),
        // .package(url: "https://github.com/IBM-Swift/Kitura-Request.git", from: "0.0.0")
    ],
    targets: [
        .target(
            name: "HTTPClient",
            dependencies: [
                "LoggerAPI",
                // "KituraRequest"
            ]
        ),
        .testTarget(name: "HTTPClientTests", dependencies: ["HTTPClient"])
    ]
)

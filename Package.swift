// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SygicUbiKit",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "SygicUbiKit",
            targets: ["SygicUbiKit"]),
    ],
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "SygicUbiKit",
            url: "https://github.com/henrich-mauritz/SygicUbiKit/releases/download/4.1.27/SygicUbiKit.xcframework-4.1.27.zip",
            checksum: "22d600b1c3f682188c4d3d6fa9bfab028afd8118868ef3d6c3137513a77cdf8d")
    ]
)

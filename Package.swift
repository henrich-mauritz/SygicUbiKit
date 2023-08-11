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
            url: "https://github.com/henrich-mauritz/SygicUbiKit/releases/download/4.2.6/SygicUbiKit.xcframework-4.2.6.zip",
            checksum: "fbdc8e9d084e05437581a0f0713f71920ff9560e5ce91fce525d0195b3751764")
    ]
)

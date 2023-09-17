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
            url: "https://github.com/henrich-mauritz/SygicUbiKit/releases/download/4.2.9/SygicUbiKit.xcframework-4.2.9.zip",
            checksum: "b1e83559f9b72fbef25640e99d9f9d5ca0f4b14246005f7c84d2e45ef5b33f40")
    ]
)

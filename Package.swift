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
            url: "https://github.com/henrich-mauritz/SygicUbiKit/releases/download/4.3.7/SygicUbiKit.xcframework-4.3.7.zip",
            checksum: "347879221a751c309611911babe8f7f0ae4977dbb485deaf9f942e549e796078")
    ]
)

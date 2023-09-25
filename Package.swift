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
            url: "https://github.com/henrich-mauritz/SygicUbiKit/releases/download/4.2.13/SygicUbiKit.xcframework-4.2.13.zip",
            checksum: "6bfc1b80b13cc5fb2b562ddf5afe6269c4e2df31a93ef4e95b76952fc92158ee")
    ]
)

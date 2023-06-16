// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SygicUbiKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(
            name: "SygicUbiKit",
            targets: ["SygicUbiKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Swinject/Swinject.git", from: "2.8.3"),
        .package(url: "https://github.com/scenee/FloatingPanel.git", from: "2.6.2"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.2"),
        .package(url: "https://github.com/henrich-mauritz/SygicMaps.git", from: "22.1.2"),
        .package(url: "https://github.com/henrich-mauritz/Driving.git", from: "2.4.0"),
        .package(url: "https://github.com/henrich-mauritz/VisionLib.git", from: "1.2.21"),
        .package(url: "https://github.com/henrich-mauritz/SygicAuth.git", from: "1.3.1"),
        .package(url: "https://github.com/henrich-mauritz/YoutubePlayer.git", from: "1.0.4"),
        .package(url: "https://github.com/henrich-mauritz/AppAuth.git", from: "1.6.2"),
        .package(url: "https://github.com/raphaelmor/Polyline.git", from: "5.0.2")
    ],
    targets: [
        .target(
            name: "SygicUbiKit",
            dependencies: [
                "Swinject",
                "FloatingPanel",
                "KeychainAccess",
                "SygicMaps",
                "Driving",
                "VisionLib",
                "SygicAuth",
                "YoutubePlayer",
                "AppAuth",
                "Polyline"
            ]),
    ]
)

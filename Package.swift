// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "SlidingRuler",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "SlidingRuler",
            targets: ["SlidingRuler"])
    ],
    dependencies: [
        .package(url: "https://github.com/Pyroh/SmoothOperators.git", .upToNextMajor(from: "0.4.0")),
        .package(url: "https://gitlab.com/Pyroh/CoreGeometry.git", .upToNextMajor(from: "4.0.0")),
    ],
    targets: [
        .target(
            name: "SlidingRuler",
            dependencies: ["SmoothOperators", "CoreGeometry"])
    ]
)

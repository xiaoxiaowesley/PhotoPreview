// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "PhotoPreview",
    platforms: [
        .iOS(.v13) 
    ],
    products: [
        .library(
            name: "PhotoPreview",
            targets: ["PhotoPreview"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "5.20.0"),
    ],
    targets: [
        .target(
            name: "PhotoPreview",
            dependencies: ["SDWebImage"]),
        .testTarget(
            name: "PhotoPreviewTests",
            dependencies: ["PhotoPreview"]),
    ]
)

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
        // 添加 SDWebImage 依赖
        .package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "5.20.0"), // 确保使用适当版本
    ],
    targets: [
        .target(
            name: "PhotoPreview",
            dependencies: ["SDWebImage"]), // 引用 SDWebImage
        .testTarget(
            name: "PhotoPreviewTests",
            dependencies: ["PhotoPreview"]),
    ]
)

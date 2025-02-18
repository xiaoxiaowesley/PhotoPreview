# PhotoPreview
<a href="README.md">English Version</a>

iOS 轻量级图片预览组件，支持手势缩放、跨平台兼容（Web/Flutter），采用解耦架构实现无缝集成，提供原生级过渡动画体验。


![PhotoPreview](intro.gif)

## 功能
- **点击/拖动关闭**: 用户可以通过点击或向下拖动预览来关闭照片预览。
- **缩放**: 双击或者用两个手指捏合来放大和缩小图像，以获得更好的观看体验。
- **解耦设计**: 您只需指定位置、大小和其他信息。支持自定义协议以最小化对 UIImageView 和 WebView 的入侵。
- **自动播放支持**: 无缝浏览图像，支持自动播放模式。
- **跨技术栈兼容性**: 在图像位于 WebView 或类似框架（如 Flutter）的情况下，您可以获取图像的位置、URL 和大小信息，以在您的原生应用中显示预览。

## 安装

您可以使用 Swift 包管理器（SPM）安装 `PhotoPreview`。具体步骤如下：

1. 打开您的 Xcode 项目。
2. 选择 `文件` > `添加包...`。
3. 输入 `PhotoPreview` 的仓库 URL。
4. 选择您想要安装的版本，然后点击 `添加包`。

## 使用方法

### 在 `ViewController` 中的示例使用

有两种主要方法可以使用 `PhotoPreviewViewController`：通过原生 UIImageView 或者 WebView。

#### 1. 使用 UIImageView

获取被点击的 `UIImageView` 对象，并为该图像创建一个 `ImageInfo` 对象。然后，用 `ImageInfo` 对象创建 `PhotoPreviewViewController` 并展示它。

```swift
guard let image = imageView.image else { return }
let frameOfImage = imageView.convert(imageView.bounds, to: UIApplication.shared.windows.first)

// 为被点击的图像创建 ImageInfo
let imageInfo = ImageInfo(image: PhotoPreviewUIImageImage(image: image),
                            frame: frameOfImage,
                            size: image.size,
                            contentMode: imageView.contentMode)

// 创建 PhotoPreviewViewController
let vc = PhotoPreviewViewController(target: PhotoPreview.Target(targetIndex: index, imageInfos: [imageInfo]))

vc.modalPresentationStyle = .custom
vc.transitioningDelegate = vc
vc.delegate = self
present(vc, animated: true)
```

#### 2. 使用 WebView

获取图像 URL、屏幕坐标中的矩形以及源图像大小，然后创建一个 ImageInfo 对象。最后，使用 ImageInfo 对象创建 PhotoPreviewViewController 并展示它。

```swift

    // Get the image URL
    let url = ...
    // Get the image rect in Screen coordinates
    let rectInScreen = .. 
    // Get the source image size
    let height = .. 
    let width =  ..

    // Create ImageInfo directly for the image
    let imageInfo = ImageInfo(image: url,
                                frame: rectInScreen,
                                size: CGSize(width: width, height: height),
                                contentMode: .scaleAspectFill)

    // Create PhotoPreviewViewController with a single image info
    let vc = PhotoPreviewViewController(target: PhotoPreview.Target(targetIndex: 0, imageInfos: [imageInfo]))

    vc.modalPresentationStyle = .custom
    vc.transitioningDelegate = vc
    vc.delegate = self
    present(vc, animated: true)


```
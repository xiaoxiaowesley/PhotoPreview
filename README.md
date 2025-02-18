# PhotoPreview
<a href="README_CN.md">中文文档</a>

Lightweight image preview component for iOS, supporting gesture-based zooming and cross-technology compatibility (WebView/Flutter). With its decoupled architecture design, it achieves seamless integration and delivers native-level transition animations.

![PhotoPreview](intro.gif)

## Features
- **Tap/Drag to Close**: Users can close the photo preview by tapping or dragging down on the preview.
- **Zooming**: Double tap or pinch with two fingers to zoom in and out of images for a better viewing experience.
- **Decoupled Design**: You only need to specify the location, size, and other information. It supports custom protocols to minimize intrusions into UIImageView and WebView.
- **Autoplay Support**: Seamlessly scroll through images in autoplay mode.
- **Cross-Technology Stack Compatibility**: In scenarios where images are in a WebView or similar frameworks (like Flutter), you can acquire the image's position, URL, and size information to display the preview in your native app.

## Installation

You can install `PhotoPreview` using Swift Package Manager (SPM). To do this, follow these steps:

1. Open your Xcode project.
2. Go to `File` > `Add Packages...`.
3. Enter the repository URL for `https://github.com/xiaoxiaowesley/PhotoPreview.git`.
4. Select the version you want to install, and click `Add Package`.

## Usage


There are two main ways to use `PhotoPreviewViewController`: through a native UIImageView or a Cross Platform Usage (In WebView).

#### 1. Using UIImageView

Get the `UIImageView` object, and create an `ImageInfo` object for the tapped image. Then, create a `PhotoPreviewViewController` with the `ImageInfo` object and present it.

```swift
    guard let image = imageView.image else { return }
    let frameOfImage = imageView.convert(imageView.bounds, to: UIApplication.shared.windows.first)

    // Create ImageInfo for the tapped image
    let imageInfo = ImageInfo(image: PhotoPreviewUIImageImage(image: image),
                                frame: frameOfImage,
                                size: image.size,
                                contentMode: imageView.contentMode)

    // Create PhotoPreviewViewController
    let vc = PhotoPreviewViewController(target: PhotoPreview.Target(targetIndex: index, imageInfos: [imageInfo]))

    vc.modalPresentationStyle = .custom
    vc.transitioningDelegate = vc
    vc.delegate = self
    present(vc, animated: true)
```

### 2. Cross Platform Usage (In WebView) 

Get the image URL, the rectangle of the image in screen coordinates, and the size of the source image. Then, create an ImageInfo object. Finally, create a PhotoPreviewViewController with the ImageInfo object and present it.

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
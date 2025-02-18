//
//
//  PhotoPreviewCell.swift
//  PhotoPreview
//
//  Created by xiaoxiang's m1 mbp on 2024/11/12.
//

import UIKit

class PhotoPreviewCell: UICollectionViewCell {

    var imageInfo: ImageInfo? {
        didSet {
            configureForNewImage(animated: false)
        }
    }

    open var scrollView: UIScrollView
    public let imageView: CustomImageView

    // 下载按钮
    let downloadButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "download"), for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
//        button.addBlurEffect()
        return button
    }()

    // 查看原图按钮
    let originalImageButton: UIButton = {
        let button = UIButton()
        button.setTitle("查看原图", for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 23.5, bottom: 0, right: 23.5)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
//        button.addBlurEffect()
        return button
    }()

    /// 加载菊花
    var loadingview: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .black
        indicator.hidesWhenStopped = true
        return indicator
    }()

    override init(frame: CGRect) {

        imageView = CustomImageView()
        scrollView = UIScrollView(frame: frame)
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        super.init(frame: frame)
        var scrollViewConstraints: [NSLayoutConstraint] = []
        var imageViewConstraints: [NSLayoutConstraint] = []

        scrollViewConstraints.append(
            NSLayoutConstraint(
                item: scrollView,
                attribute: .leading,
                relatedBy: .equal,
                toItem: contentView,
                attribute: .leading,
                multiplier: 1,
                constant: 0))

        scrollViewConstraints.append(
            NSLayoutConstraint(
                item: scrollView,
                attribute: .top,
                relatedBy: .equal,
                toItem: contentView,
                attribute: .top,
                multiplier: 1,
                constant: 0))

        scrollViewConstraints.append(
            NSLayoutConstraint(
                item: scrollView,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: contentView,
                attribute: .trailing,
                multiplier: 1,
                constant: 0))

        scrollViewConstraints.append(
            NSLayoutConstraint(
                item: scrollView,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: contentView,
                attribute: .bottom,
                multiplier: 1,
                constant: 0))

        contentView.addSubview(scrollView)
        contentView.addConstraints(scrollViewConstraints)

        imageViewConstraints.append(
            NSLayoutConstraint(
                item: imageView,
                attribute: .leading,
                relatedBy: .equal,
                toItem: scrollView,
                attribute: .leading,
                multiplier: 1,
                constant: 0))

        imageViewConstraints.append(
            NSLayoutConstraint(
                item: imageView,
                attribute: .top,
                relatedBy: .equal,
                toItem: scrollView,
                attribute: .top,
                multiplier: 1,
                constant: 0))

        imageViewConstraints.append(
            NSLayoutConstraint(
                item: imageView,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: scrollView,
                attribute: .trailing,
                multiplier: 1,
                constant: 0))

        imageViewConstraints.append(
            NSLayoutConstraint(
                item: imageView,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: scrollView,
                attribute: .bottom,
                multiplier: 1,
                constant: 0))

        scrollView.addSubview(imageView)
        scrollView.addConstraints(imageViewConstraints)
        scrollView.delegate = self
        imageView.delegate = self

        setupGestureRecognizer()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc public func doubleTapAction(recognizer: UITapGestureRecognizer) {

        if scrollView.zoomScale > scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        }
    }

    // 比例以保持内容的宽高比，同时确保内容完整地填入视图边界而不会超出
    static func calculateAspectFitRect(for imageSize: CGSize) -> CGRect {
        let containerSize: CGSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        // 计算宽高比
        let imageAspectRatio = imageSize.width / imageSize.height
        let containerAspectRatio = containerSize.width / containerSize.height

        var finalSize: CGSize

        // 根据宽高比选择缩放方式
        if imageAspectRatio > containerAspectRatio {
            // 图片更宽，基于容器的宽度计算高度
            finalSize = CGSize(width: containerSize.width, height: containerSize.width / imageAspectRatio)
        } else {
            // 图片更高，基于容器的高度计算宽度
            finalSize = CGSize(width: containerSize.height * imageAspectRatio, height: containerSize.height)
        }

        // 计算居中坐标
        let xOffset = (containerSize.width - finalSize.width) / 2
        let yOffset = (containerSize.height - finalSize.height) / 2

        return CGRect(x: xOffset, y: yOffset, width: finalSize.width, height: finalSize.height)
    }

    func configureForNewImage(animated: Bool = true) {
        guard let source = self.imageInfo else { return }

        // 最小只能缩放到 scrollView.frame.size.width 的倍率
        let minScale: CGFloat = 0.5
        let width = self.scrollView.frame.size.width / minScale
        var height: CGFloat = 0

        // 处理 UIImageImage
        if let uiimage = source.image as? PhotoPreviewUIImageImage {
            height = uiimage.image.size.height * width / uiimage.image.size.width
            imageView.configure(image: uiimage.image)
            // 更新 ImageView 的 frame 和 ScrollView 的设置
            updateImageViewFrame(width: width, height: height)
        } else if let uiimageUrl = source.image as? PhotoPreviewURLImage {
            if source.size.width == 0 || source.size.height == 0 {
                // 若图像尺寸未知，通过 URL 配置图像
                imageView.configure(url: uiimageUrl.url) { [weak self] image in
                    guard let self = self, let downloadedImage = image else { return }
                    height = downloadedImage.size.height * width / downloadedImage.size.width
                    self.updateImageViewFrame(width: width, height: height)
                }
                return
            } else {
                height = source.size.height * width / source.size.width
                imageView.configure(url: uiimageUrl.url)
                // 更新 ImageView 的 frame 和 ScrollView 的设置
                updateImageViewFrame(width: width, height: height)
            }
        }

        // 出场动画
        if animated {
            imageView.alpha = 0.0
            UIView.animate(withDuration: 0.5) {
                self.imageView.alpha = 1.0
            }
        }
    }

    // 用于设置 ImageView 的 frame 和 scrollView
    private func updateImageViewFrame(width: CGFloat, height: CGFloat) {
        imageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        setZoomScale()
        scrollViewDidZoom(scrollView)
        originalImageButton.isHidden = true
    }

    // MARK: Private Methods

    private func setupGestureRecognizer() {

        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction(recognizer:)))
        doubleTap.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTap)
    }

    private func setZoomScale() {
        let imageViewSize = imageView.bounds.size
        let scrollViewSize = scrollView.bounds.size
        let widthScale = scrollViewSize.width / imageViewSize.width
        let heightScale = scrollViewSize.height / imageViewSize.height
        scrollView.minimumZoomScale = min(widthScale, heightScale)
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
    }

    // MARK: - Handlers
    @objc private func handleDownload() {
        imageView.saveImageToLocal()
    }

    @objc private func handleOriginalImage() {
//        imageView.downloadOriginalImage { receivedSize, expectedSize in
//            let text = "\(NSLocalizedString("View original image", tableName: "Common", bundle: Bundle.localizedBundle(), comment: "查看原图")) \(Int(receivedSize) * 100 / Int(expectedSize))%"
//
//            Log.d("PhotoPreviewCell", "progress:\(Int(receivedSize) * 100 / Int(expectedSize))%")
//            self.originalImageButton.setTitle(text, for: .normal)
//
//        } completion: { success, image, error in
//            if success {
//                self.originalImageButton.isHidden = true
//            }
//        }

    }

}

// MARK: UIScrollViewDelegate Methods
extension PhotoPreviewCell: UIScrollViewDelegate {

    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {

        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size

        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0

        if verticalPadding >= 0 {
            // Center the image on screen
            scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
        } else {
            // Limit the image panning to the screen bounds
            scrollView.contentSize = imageViewSize
        }
    }

}

extension PhotoPreviewCell: CustomImageViewDelegate {
    func didLoadOriginalImage(url: String) {
        self.originalImageButton.isHidden = true
    }
}

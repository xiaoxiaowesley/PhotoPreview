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

    // Calculates the aspect fit rect to maintain content's aspect ratio while ensuring full visibility
    static func calculateAspectFitRect(for imageSize: CGSize) -> CGRect {
        let containerSize: CGSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        // Calculate aspect ratios
        let imageAspectRatio = imageSize.width / imageSize.height
        let containerAspectRatio = containerSize.width / containerSize.height

        var finalSize: CGSize

        // Determine scaling method based on aspect ratios
        if imageAspectRatio > containerAspectRatio {
            // Wider image: calculate height based on container width
            finalSize = CGSize(width: containerSize.width, height: containerSize.width / imageAspectRatio)
        } else {
            // Taller image: calculate width based on container height
            finalSize = CGSize(width: containerSize.height * imageAspectRatio, height: containerSize.height)
        }

        // Calculate centering coordinates
        let xOffset = (containerSize.width - finalSize.width) / 2
        let yOffset = (containerSize.height - finalSize.height) / 2

        return CGRect(x: xOffset, y: yOffset, width: finalSize.width, height: finalSize.height)
    }

    func configureForNewImage(animated: Bool = true) {
        guard let source = self.imageInfo else { return }

        // Minimum scale factor relative to scrollView's width
        let minScale: CGFloat = 0.5
        let width = self.scrollView.frame.size.width / minScale
        var height: CGFloat = 0

        // Handle UIImageImage
        if let uiimage = source.image as? PhotoPreviewUIImageImage {
            height = uiimage.image.size.height * width / uiimage.image.size.width
            imageView.configure(image: uiimage.image)
            // Update imageView frame and scrollView settings
            updateImageViewFrame(width: width, height: height)
        } else if let uiimageUrl = source.image as? PhotoPreviewURLImage {
            if source.size.width == 0 || source.size.height == 0 {
                // Configure via URL when image dimensions are unknown
                imageView.configure(url: uiimageUrl.url) { [weak self] image in
                    guard let self = self, let downloadedImage = image else { return }
                    height = downloadedImage.size.height * width / downloadedImage.size.width
                    self.updateImageViewFrame(width: width, height: height)
                }
                return
            } else {
                height = source.size.height * width / source.size.width
                imageView.configure(url: uiimageUrl.url)
                // Update imageView frame and scrollView settings
                updateImageViewFrame(width: width, height: height)
            }
        }

        // Entrance animation
        if animated {
            imageView.alpha = 0.0
            UIView.animate(withDuration: 0.5) {
                self.imageView.alpha = 1.0
            }
        }
    }

    // Updates imageView frame and scrollView configuration
    private func updateImageViewFrame(width: CGFloat, height: CGFloat) {
        imageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        setZoomScale()
        scrollViewDidZoom(scrollView)
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
            // Limit panning to screen bounds
            scrollView.contentSize = imageViewSize
        }
    }
}

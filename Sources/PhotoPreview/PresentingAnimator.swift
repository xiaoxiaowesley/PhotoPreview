//
//  PresentingAnimator.swift
//  PhotoPreview
//
//  Created by xiaoxiang's m1 mbp on 2024/11/12.
//
import Foundation
import UIKit
import SDWebImage

class PresentingAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    private let imageInfo: ImageInfo
    private let pageIndex: Int
    private let duration: TimeInterval = 0.3

    init(pageIndex: Int, imageInfo: ImageInfo) {
        self.pageIndex = pageIndex
        self.imageInfo = imageInfo
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: .to),
            let toVC = transitionContext.viewController(forKey: .to)
        else {
            transitionContext.completeTransition(false)
            return
        }

        // 开始beginFrame ，这里为了和webview保持一致，使用的是像素单位
        var beginFrame = imageInfo.frame!
        let viewToAnimate = UIImageView(frame: beginFrame)
        viewToAnimate.clipsToBounds = true

        if imageInfo.image is PhotoPreviewUIImageImage {
            let uiimage = imageInfo.image as! PhotoPreviewUIImageImage
            viewToAnimate.image = uiimage.image
        } else if imageInfo.image is PhotoPreviewURLImage {
            let source = imageInfo.image as! PhotoPreviewURLImage
            if let resourceData = SDImageCache.shared.diskImageData(forKey: source.url) {
                viewToAnimate.image = UIImage(data: resourceData)
            } else {
                guard let u = URL(string: source.url ) else { return }
                viewToAnimate.sd_setImage(with: u)
            }
        }
        viewToAnimate.contentMode = imageInfo.contentMode

        let containerView = transitionContext.containerView
        containerView.addSubview(toView)
        containerView.addSubview(viewToAnimate)

        toView.isHidden = true

        // finalSize 获取的优先级 viewToAnimate.image?.size  > imageInfo.size > .zero
        let finalSize = viewToAnimate.image?.size ?? imageInfo.size ?? .zero        
        // 结果frame: 比例以保持内容的宽高比，同时确保内容完整地填入视图边界而不会超出
        let finalFrame = PhotoPreviewCell.calculateAspectFitRect(for: finalSize)

        UIView.animate(
            withDuration: duration,
            animations: {
                viewToAnimate.frame = finalFrame
            },
            completion: { _ in
                toView.isHidden = false
                viewToAnimate.removeFromSuperview()
                transitionContext.completeTransition(true)

                // 设置默认的index
                let previewViewController = toVC as? PhotoPreviewViewController
                previewViewController?.currentPage = self.pageIndex
            })

    }
}

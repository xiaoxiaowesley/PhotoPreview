//
//  DismissingAnimator.swift
//  PhotoPreview
//
//  Created by xiaoxiang's m1 mbp on 2024/11/12.
//

import Foundation
import UIKit
import SDWebImage

class DismissingAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let imageInfo: ImageInfo
    private let animationDuration: TimeInterval = 0.2
    private let pageIndex: Int

    init(pageIndex: Int, imageInfo: ImageInfo) {
        self.imageInfo = imageInfo
        self.pageIndex = pageIndex
    }

    func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        return animationDuration
    }

    func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from) else {
            transitionContext.completeTransition(false)
            return
        }

        let containerView = transitionContext.containerView

        guard let previewViewController = fromVC as? PhotoPreviewViewController,
            let originCell = previewViewController.getCell(from: pageIndex)
        else {
            return
        }

        // Begin Frame
        let beginFrame = originCell.imageView.superview?.convert(originCell.imageView.frame, to: UIApplication.shared.windows.first) ?? CGRect.zero

        let viewToAnimate: UIImageView = UIImageView()
        viewToAnimate.contentMode = .scaleAspectFit
        viewToAnimate.frame = beginFrame
        
        // initial image
        if imageInfo.image is PhotoPreviewUIImageImage {
            let uiimage = imageInfo.image as! PhotoPreviewUIImageImage
            viewToAnimate.image = uiimage.image
        } else if imageInfo.image is PhotoPreviewURLImage {
            let source = imageInfo.image as! PhotoPreviewURLImage
            if let resourceData = SDImageCache.shared.diskImageData(forKey: source.url) {
                viewToAnimate.image = UIImage(data: resourceData)
            }
        }

        containerView.addSubview(viewToAnimate)

        // end frame
        var endFrame = imageInfo.frame!
        viewToAnimate.clipsToBounds = true
        viewToAnimate.contentMode = self.imageInfo.contentMode

        originCell.isHidden = true
        UIView.animate(
            withDuration: animationDuration,
            animations: {
                previewViewController.view.alpha = 0.0
                viewToAnimate.frame = endFrame
            }
        ) { _ in
            print("transitionContext.completeTransition")
            viewToAnimate.removeFromSuperview()
            transitionContext.completeTransition(true)
        }
    }
}

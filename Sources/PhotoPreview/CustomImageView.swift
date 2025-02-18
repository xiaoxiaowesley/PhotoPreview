import SDWebImage
import UIKit

protocol CustomImageViewDelegate: AnyObject {
    func didLoadOriginalImage(url: String)
}

class CustomImageView: UIImageView {

    weak var delegate: CustomImageViewDelegate?
    private var imageURL: String? = nil
    private var loadingView: UIActivityIndicatorView = UIActivityIndicatorView(style: .medium)

    private func setupLoadingIndicator() {
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.hidesWhenStopped = true
        addSubview(loadingView)

        // Center the loading indicator in the image view
        NSLayoutConstraint.activate([
            loadingView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }

    func configure(url: String, completion: ((UIImage?) -> Void)? = nil) {
        self.imageURL = url
        setupLoadingIndicator()
        loadImage(from: url, completion: completion)
    }

    func configure(image: UIImage) {
        self.image = image
    }

    private func loadImage(from url: String, completion: ((UIImage?) -> Void)? = nil) {

        var downloadUrl = url
//        // 如果本地已经有原图，直接使用原图
//        if SDImageCache.shared.diskImageExists(withKey: url.getOriginImage()) {
//            downloadUrl = url.getOriginImage()
//        }

        if let u = URL(string: downloadUrl) {
//            if SDImageCache.shared.diskImageExists(withKey: downloadUrl),
//                let resourceData = SDImageCache.shared().diskImageDataBySearchingAllPaths(forKey: downloadUrl)
//            {
//                image = UIImage(data: resourceData)
//                if downloadUrl.isOriginImage() {
//                    self.delegate?.didLoadOriginalImage(url: downloadUrl)
//                }
//                completion?(image)
//            } else {
//                loadingView.isHidden = false
//                loadingView.startAnimating()
//                let placeholder = UIImage.placeholderImage(size: CGSizeMake(100, 100))
                sd_setImage(with: u, placeholderImage: nil) { image, error, sdImageCacheType, url in
                    print("download succ sdImageCacheType:\(sdImageCacheType),url:\(String(describing: url))")
                    self.loadingView.isHidden = true
                    self.loadingView.stopAnimating()
//                    if downloadUrl.isOriginImage() {
//                        self.delegate?.didLoadOriginalImage(url: downloadUrl)
//                    }
                    completion?(image)
                }
//            }
        }
    }

    // Function to download the original image with loading indicator, progress, and completion callbacks
    func downloadOriginalImage(
        progress: @escaping (_ receivedSize: Int, _ expectedSize: Int) -> Void,
        completion: @escaping (_ success: Bool, _ image: UIImage?, _ error: Swift.Error?) -> Void
    ) {
//        guard let urlString = self.imageURL, let originUrl = URL(string: urlString.getOriginImage()) else {
//            completion(false, nil, nil)
//            return
//        }
//
//        let options: SDWebImageOptions = .retryFailed
//
//        let oldImage = self.image
//        // Start the download process
//        sd_setImage(
//            with: originUrl, placeholderImage: oldImage, options: options,
//            progress: { receivedSize, expectedSize, targetURL  in
//                // Report progress to the closure
//                progress(receivedSize, expectedSize)
//            }
//        ) { (image, error, cacheType, url) in
//
//            if let error = error {
//                print("Error downloading image: \(error.localizedDescription)")
//                completion(false, nil, error)
//                return
//            }
//
//            if let image = image {
//                self.delegate?.didLoadOriginalImage(url: urlString)
//                UIView.transition(
//                    with: self, duration: 0.5, options: .transitionCrossDissolve,
//                    animations: {
//                        self.image = image
//                    }, completion: nil)
//                completion(true, image, nil)
//            } else {
//                completion(false, nil, nil)  // No image but no error
//            }
//        }
    }

    func saveImageToLocal() {
        if let imageToSave = self.image {
//            ImageSaver.shared.saveImageToPhotoAlbum(with: imageToSave)
        } else {
            print("imageView.image is nil")
        }
    }

}

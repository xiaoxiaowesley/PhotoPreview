import SDWebImage
import UIKit

class CustomImageView: UIImageView {

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
        if let u = URL(string: url) {
            sd_setImage(with: u, placeholderImage: nil) { image, error, sdImageCacheType, url in
                print("download succ sdImageCacheType:\(sdImageCacheType),url:\(String(describing: url))")
                self.loadingView.isHidden = true
                self.loadingView.stopAnimating()
                completion?(image)
            }
        }
    }

}

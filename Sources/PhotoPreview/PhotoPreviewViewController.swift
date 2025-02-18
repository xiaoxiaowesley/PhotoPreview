import UIKit
import SDWebImage
import Foundation

@objc public  protocol PhotoPreviewDelegate {
    func didTapToClose(photoPreviewViewController: PhotoPreviewViewController)
}

public protocol PhotoPreviewImageProtocol {
    func getImage(completion: @escaping (UIImage?) -> Void)
}
public struct PhotoPreviewUIImageImage: PhotoPreviewImageProtocol {
    let image: UIImage
    
    public init(image: UIImage) {
        self.image = image
    }

    public func getImage(completion: @escaping (UIImage?) -> Void) {
        completion(image)
    }
}

public struct PhotoPreviewURLImage: PhotoPreviewImageProtocol {
    let url: String
    
    public init(url: String) {
        self.url = url
    }

    public func getImage(completion: @escaping (UIImage?) -> Void) {
    }
}


public struct ImageInfo {
    public struct Size {
        let width: CGFloat
        let height: CGFloat
        public init(width: CGFloat, height: CGFloat) {
            self.width = width
            self.height = height
        }
    }

    let image: PhotoPreviewImageProtocol  // 使用 ImageProtocol
    let frame:CGRect?
    let size: CGSize
    let contentMode: UIView.ContentMode
    
    public init(image: PhotoPreviewImageProtocol,
        frame:CGRect? = nil,
        size: CGSize,
         contentMode: UIView.ContentMode) {
        self.image = image
        self.contentMode = contentMode
        self.frame = frame
        self.size = size
    }

    static func objectFit(from contentMode: UIView.ContentMode) -> String {
        switch contentMode {
        case .scaleToFill:
            return "fill"
        case .scaleAspectFit:
            return "contain"
        case .scaleAspectFill:
            return "cover"
        case .redraw:
            return "scale-down"
        default:
            return "fill"
        }
    }
}

// 定义主结构体
public struct Target {
    let targetIndex: Int
    let imageInfos: [ImageInfo]
    
    public init(targetIndex: Int, imageInfos: [ImageInfo]) {
        self.targetIndex = targetIndex
        self.imageInfos = imageInfos
    }
}
 
public class PhotoPreviewViewController: UIViewController {
    var targetImage: Target?
    
    public init(target: Target) {
         self.targetImage = target
         super.init(nibName: nil, bundle: nil)
     }
     
    required public init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }

    public weak var delegate: PhotoPreviewDelegate?

    public lazy var imageCollectionView: UICollectionView = self.setupCollectionView()

    public var numberOfImages: Int {
        return collectionView(imageCollectionView, numberOfItemsInSection: 0)
    }

    public var backgroundColor: UIColor {
        get {
            return view.backgroundColor!
        }
        set(newBackgroundColor) {
            view.backgroundColor = newBackgroundColor
        }
    }

    public var currentPage: Int {
        set(page) {
            if page < numberOfImages {
                scrollToImage(withIndex: page, animated: false)
            } else {
                scrollToImage(withIndex: numberOfImages - 1, animated: false)
            }
        }
        get {
            return Int(imageCollectionView.contentOffset.x / imageCollectionView.frame.size.width)
        }
    }

    private var flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()

    // MARK: Lifecycle methods

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        flowLayout.itemSize = view.bounds.size
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        setupGestureRecognizers()
    }

    public override func viewDidAppear(_ animated: Bool) {
        if currentPage < 0 {
            currentPage = 0
        }
    }

    // MARK: Gesture Handlers
    private func setupGestureRecognizers() {

        let panGesture = PanDirectionGestureRecognizer(direction: PanDirection.vertical, target: self, action: #selector(wasDragged(_:)))
        imageCollectionView.addGestureRecognizer(panGesture)
        imageCollectionView.isUserInteractionEnabled = true

        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapAction(recognizer:)))
        singleTap.numberOfTapsRequired = 1
        singleTap.delegate = self
        imageCollectionView.addGestureRecognizer(singleTap)
    }

    private var originalPosition: CGPoint?

    @objc func wasDragged(_ gesture: UIPanGestureRecognizer) {
        guard let imageView = gesture.view else { return }

        let translation = gesture.translation(in: self.view)
        let velocity = gesture.velocity(in: self.view)

        switch gesture.state {
        case .began:
            originalPosition = imageView.center

        case .changed:
            if let originalPosition = originalPosition {
                let newCenter = CGPoint(
                    x: originalPosition.x + translation.x,
                    y: originalPosition.y + translation.y)
                imageView.center = newCenter

                let alpha = max(0, min(1, 1 - abs(translation.y) / self.view.bounds.height))
                backgroundColor = UIColor.black.withAlphaComponent(alpha)
            }

        case .ended:
            let shouldDismiss = velocity.y > 1000 && translation.y > 0
            if shouldDismiss {
                delegate?.didTapToClose(photoPreviewViewController: self)
            } else {
                UIView.animate(withDuration: 0.25) {
                    imageView.center = self.originalPosition ?? imageView.center
                    self.backgroundColor = UIColor.black.withAlphaComponent(1.0)
                }
            }

        default:
            break
        }
    }

    @objc public func singleTapAction(recognizer: UITapGestureRecognizer) {
        delegate?.didTapToClose(photoPreviewViewController: self)
    }

    // MARK: Private Methods

    private func setupCollectionView() -> UICollectionView {
        // Set up flow layout
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0

        // Set up collection view
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(PhotoPreviewCell.self, forCellWithReuseIdentifier: "PhotoPreviewCell")
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.clear
        collectionView.isPagingEnabled = true
        collectionView.contentInsetAdjustmentBehavior = .never

        // Set up collection view constraints
        var imageCollectionViewConstraints: [NSLayoutConstraint] = []
        imageCollectionViewConstraints.append(
            NSLayoutConstraint(
                item: collectionView,
                attribute: .leading,
                relatedBy: .equal,
                toItem: view,
                attribute: .leading,
                multiplier: 1,
                constant: 0))

        imageCollectionViewConstraints.append(
            NSLayoutConstraint(
                item: collectionView,
                attribute: .top,
                relatedBy: .equal,
                toItem: view,
                attribute: .top,
                multiplier: 1,
                constant: 0))

        imageCollectionViewConstraints.append(
            NSLayoutConstraint(
                item: collectionView,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: view,
                attribute: .trailing,
                multiplier: 1,
                constant: 0))

        imageCollectionViewConstraints.append(
            NSLayoutConstraint(
                item: collectionView,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: view,
                attribute: .bottom,
                multiplier: 1,
                constant: 0))

        view.addSubview(collectionView)
        view.addConstraints(imageCollectionViewConstraints)

        collectionView.contentSize = CGSize(width: 1000.0, height: 1.0)

        return collectionView
    }

    private func scrollToImage(withIndex: Int, animated: Bool = false) {
        imageCollectionView.scrollToItem(at: IndexPath(item: withIndex, section: 0), at: .centeredHorizontally, animated: animated)
    }

    /// 获取cell
    /// - Parameter pageIndex: 索引
    func getCell(from pageIndex: Int) -> PhotoPreviewCell? {
        guard let cell = imageCollectionView.cellForItem(at: IndexPath(item: pageIndex, section: 0)) as? PhotoPreviewCell else {
            return nil
        }
        return cell
    }
}

// MARK: UICollectionViewDataSource Methods
extension PhotoPreviewViewController: UICollectionViewDataSource {

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ imageCollectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let imageInfos = targetImage?.imageInfos else {
            print("targetImage is nil or imageInfos is empty")
            return 0
        }
        return imageInfos.count
    }

    func configurePhotoPreviewCell(_ cell: PhotoPreviewCell, at index: Int) {
        guard let sources = targetImage?.imageInfos, sources.count > 0 else {
            print("targetImage is nil or imageInfos is empty")
            return
        }
        cell.imageInfo = sources[index]
    }

    public func collectionView(_ imageCollectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imageCollectionView.dequeueReusableCell(withReuseIdentifier: "PhotoPreviewCell", for: indexPath) as! PhotoPreviewCell
        configurePhotoPreviewCell(cell, at: indexPath.item)

        return cell
    }
}

// MARK: UIGestureRecognizerDelegate Methods
extension PhotoPreviewViewController: UIGestureRecognizerDelegate {

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {

        return otherGestureRecognizer is UITapGestureRecognizer && gestureRecognizer is UITapGestureRecognizer && otherGestureRecognizer.view is PhotoPreviewCell
            && gestureRecognizer.view == imageCollectionView
    }
}



// MARK: PhotoPreviewDelegate Methods
extension PhotoPreviewViewController: PhotoPreviewDelegate {

    public func didTapToClose(photoPreviewViewController: PhotoPreviewViewController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: 转场
extension PhotoPreviewViewController: UIViewControllerTransitioningDelegate {

    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return DimmingPresentationController(presentedViewController: presented, presenting: presenting)
    }

    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        guard let targetImage = self.targetImage else {
            print("forPresented target is nil")
            return nil
        }
        let imageInfo = targetImage.imageInfos[targetImage.targetIndex]

        return PresentingAnimator(pageIndex: targetImage.targetIndex, imageInfo: imageInfo)
    }
    public func animationController(forDismissed dismissed: UIViewController)
        -> UIViewControllerAnimatedTransitioning?
    {
        guard let targetImage = self.targetImage else {
            print("forPresented target is nil")
            return nil
        }
        let imageInfo = targetImage.imageInfos[currentPage]
        return DismissingAnimator(pageIndex: currentPage, imageInfo: imageInfo)

    }
}

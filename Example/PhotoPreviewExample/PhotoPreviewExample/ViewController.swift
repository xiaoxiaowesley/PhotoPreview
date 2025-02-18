//
//  ViewController.swift
//  PhotoPreviewExample
//  Created by xiaoxiang's m1 mbp on 2025/2/17.


import UIKit
import PhotoPreview
import WebKit

class ViewController: UIViewController, PhotoPreviewDelegate, WKScriptMessageHandler {
    
    // List of image names
    let imageNames: [String] = ["beach", "forest", "hiking", "mountain"]
    var imageViews: [UIImageView] = []
    
    var webView: WKWebView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Setup UIImageView
        let label = UILabel(frame: CGRect(x: 0, y: 50, width: self.view.frame.width, height: 50))
        label.text = "Tap to show preview(UIImage)"
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20)
        view.addSubview(label)
        
        // Generate UIImageViews based on imageNames
        for i in 0..<imageNames.count {
            // Row and column calculation
            let row = i % 2
            let col = i / 2
            let imageView = UIImageView(frame: CGRect(x: CGFloat(row) * self.view.frame.size.width / 2,
                                                       y: CGFloat(col) * self.view.frame.size.width / 2 + 100,
                                                       width: self.view.frame.size.width / 2,
                                                       height: self.view.frame.size.width / 2))
            imageView.image = UIImage(named: imageNames[i])
            imageView.contentMode = .scaleAspectFill
            imageView.isUserInteractionEnabled = true
            imageView.clipsToBounds = true
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapImageView)))
            view.addSubview(imageView)
            imageViews.append(imageView)
        }
        
        // 2. Setup webview
        let contentController = WKUserContentController()
        contentController.add(self, name: "nativeFunction") // Register message handler
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        webView = WKWebView(frame: .zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false // Use Auto Layout
        view.addSubview(webView)
        
        // Load local or remote HTML file
        if let url = Bundle.main.url(forResource: "index", withExtension: "html") {
            webView.loadFileURL(url, allowingReadAccessTo: url)
        }

        // Set Auto Layout constraints for webView
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: imageViews.last?.bottomAnchor ?? label.bottomAnchor, constant: 20),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc func tapImageView(gesture: UITapGestureRecognizer) {
        // Get the tapped UIImageView
        guard let tappedImageView = gesture.view as? UIImageView,
              let index = imageViews.firstIndex(of: tappedImageView) else { return }
        
        var imageInfos: [ImageInfo] = []
        // Generate imageInfos
        for i in 0..<imageNames.count {
            guard let image = imageViews[i].image else { return }
            let frameOfImage = imageViews[i].convert(imageViews[i].bounds, to: UIApplication.shared.windows.first)
            imageInfos.append(ImageInfo(image: PhotoPreviewUIImageImage(image: image),
                                        frame: frameOfImage,
                                        size: image.size,
                                        contentMode: imageViews[i].contentMode))
        }
        
        // Create PhotoPreviewViewController
        let vc = PhotoPreviewViewController(target: PhotoPreview.Target(targetIndex: index, imageInfos: imageInfos))
        
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = vc
        vc.delegate = self
        present(vc, animated: true)
    }
    
    public func didTapToClose(photoPreviewViewController: PhotoPreviewViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "nativeFunction" {
            if let messageBody = message.body as? String {
                print("JavaScript is sending data: \(messageBody)")
                // Try to convert JSON string to dictionary
                if let data = messageBody.data(using: .utf8) {
                    do {
                        // Parse to dictionary
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let imageData = json["data"] as? [[String: Any]],
                           let index = json["index"] as? Int {
                            // Call handling function
                            myNativeFunction(arg: imageData, index: index)
                        }
                    } catch {
                        print("Error parsing JSON: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    func myNativeFunction(arg: [[String: Any]], index: Int) {
        var imageInfos: [ImageInfo] = [] // Array to store all ImageInfo
        
        for item in arg {
            // Iterate through each item
            let x = item["x"] as? CGFloat ?? 0
            let y = item["y"] as? CGFloat ?? 0
            let width = item["width"] as? CGFloat ?? 0
            let height = item["height"] as? CGFloat ?? 0
            let imageUrl = item["imageUrl"] as? String ?? ""
            let imageSize = item["imageSize"] as? [String: Any] ?? [:]
            let imageWidth: CGFloat = imageSize["width"] as? CGFloat ?? 0
            let imageHeight: CGFloat = imageSize["height"] as? CGFloat ?? 0
            
            print("Received image position and size - x: \(x), y: \(y), width: \(width), height: \(height), url: \(imageUrl)")
            
            let rectInWebView = CGRect(x: x, y: y, width: width, height: height)
            let rectInScreen = webView.convert(rectInWebView, to: view)
            
            let url = PhotoPreviewURLImage(url: imageUrl)
            
            // Add each ImageInfo to the array
            let imageInfo = ImageInfo(image: url, frame: rectInScreen, size: CGSize(width: imageWidth, height: imageHeight), contentMode: .scaleAspectFill)
            imageInfos.append(imageInfo)
        }
        
        // Create a PhotoPreviewViewController, passing in the index
        let vc = PhotoPreviewViewController(target: PhotoPreview.Target(targetIndex: index, imageInfos: imageInfos))
        
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = vc
        vc.delegate = self
        present(vc, animated: true)
    }
}

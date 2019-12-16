//
//  ViewController.swift
//  PPT_Process
//
//  Created by BrandonZu on 2019/11/30.
//  Copyright © 2019 DongjueZu. All rights reserved.
//

import UIKit
import MobileCoreServices
import Photos
import Vision

class HomepageViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    // Layer into which to draw bounding box paths.
    var pathLayer: CALayer?
    
    // Image parameters for reuse throughout app
    var imageWidth: CGFloat = 0
    var imageHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func TakePhotoTouched(_ sender: UIButton) {
//        VideoHelper.startMediaBrowser(delegate: self, sourceType: .camera)
        promptPhoto()
    }
    
    func promptPhoto() {
        
        let prompt = UIAlertController(title: "选择照片", message: "请选择一个照片", preferredStyle: .actionSheet)
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        //从相机中选择
        func fromCamera(_ _: UIAlertAction) {
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true)
        }
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: fromCamera)
        
        //从Library中选择
        func fromLibrary(_ _: UIAlertAction) {
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true)
        }
        
        let libraryAction = UIAlertAction(title: "Photo Library", style: .default, handler: fromLibrary)
        
        //从相册中选择
        func fromAlbums(_ _: UIAlertAction) {
            imagePicker.sourceType = .savedPhotosAlbum
            self.present(imagePicker, animated: true)
        }
        
        let albumsAction = UIAlertAction(title: "Saved Albums", style: .default, handler: fromAlbums)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        prompt.addAction(cameraAction)
        prompt.addAction(libraryAction)
        prompt.addAction(albumsAction)
        prompt.addAction(cancelAction)
        
        self.present(prompt, animated: true, completion: nil)
    }
}

// MARK: - Helper Methods

/// - Tag: PreprocessImage
func scaleAndOrient(image: UIImage) -> UIImage {
    
    // Set a default value for limiting image size.
    let maxResolution: CGFloat = 640
    
    guard let cgImage = image.cgImage else {
        print("UIImage has no CGImage backing it!")
        return image
    }
    
    // Compute parameters for transform.
    let width = CGFloat(cgImage.width)
    let height = CGFloat(cgImage.height)
    var transform = CGAffineTransform.identity
    
    var bounds = CGRect(x: 0, y: 0, width: width, height: height)
    
    if width > maxResolution || height > maxResolution {
        let ratio = width / height
        if width > height {
            bounds.size.width = maxResolution
            bounds.size.height = round(maxResolution / ratio)
        }
        else {
            bounds.size.width = round(maxResolution * ratio)
            bounds.size.height = maxResolution
        }
    }
    
    let scaleRatio = bounds.size.width / width
    let orientation = image.imageOrientation
    
    switch orientation {
    case .up:
        transform = .identity
    case .down:
        transform = CGAffineTransform(translationX: width, y: height).rotated(by: .pi)
    case .left:
        let boundsHeight = bounds.size.height
        bounds.size.height = bounds.size.width
        bounds.size.width = boundsHeight
        transform = CGAffineTransform(translationX: 0, y: width).rotated(by: 3.0 * .pi / 2.0)
    case .right:
        let boundsHeight = bounds.size.height
        bounds.size.height = bounds.size.width
        bounds.size.width = boundsHeight
        transform = CGAffineTransform(translationX: height, y: 0).rotated(by: .pi / 2.0)
    case .upMirrored:
        transform = CGAffineTransform(translationX: width, y: 0).scaledBy(x: -1, y: 1)
    case .downMirrored:
        transform = CGAffineTransform(translationX: 0, y: height).scaledBy(x: 1, y: -1)
    case .leftMirrored:
        let boundsHeight = bounds.size.height
        bounds.size.height = bounds.size.width
        bounds.size.width = boundsHeight
        transform = CGAffineTransform(translationX: height, y: width).scaledBy(x: -1, y: 1).rotated(by: 3.0 * .pi / 2.0)
    case .rightMirrored:
        let boundsHeight = bounds.size.height
        bounds.size.height = bounds.size.width
        bounds.size.width = boundsHeight
        transform = CGAffineTransform(scaleX: -1, y: 1).rotated(by: .pi / 2.0)
    default:
        print("Unkown orientation!")
    }
    
    return UIGraphicsImageRenderer(size: bounds.size).image { rendererContext in
        let context = rendererContext.cgContext
        
        if orientation == .right || orientation == .left {
            context.scaleBy(x: -scaleRatio, y: scaleRatio)
            context.translateBy(x: -height, y: 0)
        }
        else {
            context.scaleBy(x: scaleRatio, y: -scaleRatio)
            context.translateBy(x: 0, y: -height)
        }
        context.concatenate(transform)
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
    }
}

// MARK: - UIImagePickerControllerDelegate

extension HomepageViewController: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss picker, returning to original root viewController.
        dismiss(animated: true, completion: nil)
    }

    internal func imagePickerController(_ picker: UIImagePickerController,
                                        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // Extract chosen image.
        let originalImage: UIImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        // Display image on screen.
        show(originalImage)
        
        // Convert from UIImageOrientation to CGImagePropertyOrientation.
//        let cgOrientation = CGImagePropertyOrientation(originalImage.imageOrientation)
//
//        // Fire off request based on URL of chosen photo.
//        guard let cgImage = originalImage.cgImage else {
//            return
//        }
//        performVisionRequest(image: cgImage,
//                             orientation: cgOrientation)
        
        // Dismiss the picker to return to original view controller.
        dismiss(animated: true, completion: nil)
    }

    func show(_ image: UIImage) {
        
        // Remove previous paths & image
        pathLayer?.removeFromSuperlayer()
        pathLayer = nil
        imageView.image = nil
        
        // Account for image orientation by transforming view.
//        let correctedImage = scaleAndOrient(image: image)
        let correctedImage = image
        
        // Place photo inside imageView.
        imageView.image = correctedImage
        
        // Transform image to fit screen.
        guard let cgImage = correctedImage.cgImage else {
            print("Trying to show an image not backed by CGImage!")
            return
        }
        
        let fullImageWidth = CGFloat(cgImage.width)
        let fullImageHeight = CGFloat(cgImage.height)
        
        let imageFrame = imageView.frame
        let widthRatio = fullImageWidth / imageFrame.width
        let heightRatio = fullImageHeight / imageFrame.height
        
        // ScaleAspectFit: The image will be scaled down according to the stricter dimension.
        let scaleDownRatio = max(widthRatio, heightRatio)
        
        // Cache image dimensions to reference when drawing CALayer paths.
        imageWidth = fullImageWidth / scaleDownRatio
        imageHeight = fullImageHeight / scaleDownRatio
        
        // Prepare pathLayer to hold Vision results.
        let xLayer = (imageFrame.width - imageWidth) / 2
        let yLayer = imageView.frame.minY + (imageFrame.height - imageHeight) / 2
        let drawingLayer = CALayer()
        drawingLayer.bounds = CGRect(x: xLayer, y: yLayer, width: imageWidth, height: imageHeight)
        drawingLayer.anchorPoint = CGPoint.zero
        drawingLayer.position = CGPoint(x: xLayer, y: yLayer)
        drawingLayer.opacity = 0.5
        pathLayer = drawingLayer
        self.view.layer.addSublayer(pathLayer!)
    }
}

// MARK: - UINavigationControllerDelegatee

extension HomepageViewController: UINavigationControllerDelegate {
}

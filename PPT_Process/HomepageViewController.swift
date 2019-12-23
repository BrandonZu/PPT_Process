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
import os.log
import AVFoundation

class HomepageViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var navigationTitle: UINavigationItem!
    var timer : Timer? = nil
    
    // Layer into which to draw bounding box paths.
    var pathLayer: CALayer?
    
    var srcImage: UIImage? = nil
    
    // Image parameters for reuse throughout app
    var imageWidth: CGFloat = 0
    var imageHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveCurCourseAnswer(notice:)), name: NSNotification.Name(rawValue: "CurCourseAnswer"), object: nil)
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { timer in
            let CourseRequest = Notification(name: Notification.Name(rawValue: "CourseRequest"), object: Date(), userInfo: ["info":"RepeatRequest"])
            NotificationCenter.default.post(CourseRequest)
        }
        self.timer!.fire()
    }
    
    // MARK: - Actions
    
    @objc func receiveCurCourseAnswer(notice: Notification) {
        print("get answer")
        if let answer = notice.object as? Course {
            navigationItem.title = "当前课程:" + answer.name
        }
        else {
            navigationItem.title = "当前无课程"
        }
    }
    
    @IBAction func SaveImageTouched(_ sender: UIBarButtonItem) {
        let NewPPT: Notification = Notification(name: NSNotification.Name(rawValue: "NewPPT"), object: self.imageView.image)
        NotificationCenter.default.post(NewPPT)
        presentNotice("保存成功")
    }
    
    @IBAction func TakePhotoTouched(_ sender: UIButton) {
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

    // MARK: - Helper Methods

    /// - Tag: Process Rectangle for cropping
    fileprivate func correctRect(cropRect: CGRect, bounds: CGSize) -> CGRect {
        
        let imageWidth = bounds.width
        let imageHeight = bounds.height
        
        // Begin with input rect.
        var rect = cropRect
        
        // Reposition origin.
        rect.origin.y = (1 - rect.origin.y - rect.size.height) * imageHeight
        rect.origin.x *= imageWidth
        
        // Rescale normalized coordinates.
        rect.size.width *= imageWidth
        rect.size.height *= imageHeight
        
        return rect
    }
    
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
    
    func presentAlert(_ title: String, error: NSError) {
        // Always present alert on main thread.
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title,
                                                    message: error.localizedDescription,
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK",
                                         style: .default) { _ in
                                            // Do nothing -- simply dismiss alert.
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func presentNotice(_ title: String) {
        // Always present alert on main thread.
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title,
                                                    message: "",
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK",
                                         style: .default) { _ in
                                            // Do nothing -- simply dismiss alert.
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    //MARK: - Vision
    
    lazy var rectangleDetectionRequest: VNDetectRectanglesRequest = {
        let rectDetectRequest = VNDetectRectanglesRequest(completionHandler: self.handleDetectedRectangles)
        // Set restricitions
        rectDetectRequest.maximumObservations = 4
        
        rectDetectRequest.minimumConfidence = 0.6
        
        rectDetectRequest.minimumAspectRatio = 0.3
        
        return rectDetectRequest
    }()
    
    fileprivate func createVisionRequests() -> [VNRequest] {
        var requests: [VNRequest] = []
        requests.append(self.rectangleDetectionRequest)
        return requests
    }
    
    fileprivate func performVisionRequest(image: CGImage, orientation: CGImagePropertyOrientation) {
        
        // Fetch desired requests based on switch status.
        let requests = createVisionRequests()
        // Create a request handler.
        let imageRequestHandler = VNImageRequestHandler(cgImage: image,
                                                        orientation: orientation,
                                                        options: [:])
        
        // Send the requests to the request handler.
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try imageRequestHandler.perform(requests)
            } catch let error as NSError {
                print("Failed to perform image request: \(error)")
                self.presentAlert("Image Request Failed", error: error)
                return
            }
        }
    }
    
    fileprivate func handleDetectedRectangles(request: VNRequest?, error: Error?) {
        if let nsError = error as NSError? {
            self.presentAlert("Rectangle Detection Error", error: nsError)
            return
        }
        
        // Since handlers are executing on a background thread, explicitly send draw calls to the main thread.
        DispatchQueue.main.async {
            guard let results = request?.results as? [VNRectangleObservation] else {
                    return
            }
            
            guard results.count > 0 else {
                self.presentNotice("没有找到PPT!")
                self.imageView.image = self.scaleAndOrient(image: self.srcImage!)
                return
            }
            
            var MaxRect: CGRect = results[0].boundingBox
            // Find the largest Rectangle
            for rect in results {
                if rect.boundingBox.height * rect.boundingBox.width > MaxRect.height * MaxRect.width {
                    MaxRect = rect.boundingBox
                }
            }
            
//            let previewLayer = AVCaptureVideoPreviewLayer()
//            print("before", MaxRect)
//            MaxRect = previewLayer.layerRectConverted(fromMetadataOutputRect: MaxRect)
//            print("after", MaxRect)
            
            if let scale = self.srcImage?.scale, self.srcImage?.scale != 1 {
                MaxRect.size.height *= scale
                MaxRect.size.width *= scale
                MaxRect.origin.x *= scale
                MaxRect.origin.y *= scale
            }
            
            print("before", MaxRect)
            MaxRect = self.correctRect(cropRect: MaxRect, bounds: self.srcImage!.size)
            print("after", MaxRect)
            
            if let croppedImage = self.srcImage?.cgImage?.cropping(to: MaxRect) {
                self.srcImage = UIImage(cgImage: croppedImage)
                let flipImageOrientation = self.srcImage!.imageOrientation.rawValue + 1
                //翻转图片
                let flipImage =  UIImage(cgImage:(self.srcImage?.cgImage!)!,
                                         scale:self.srcImage!.scale,
                                         orientation:UIImage.Orientation(rawValue: flipImageOrientation)!
                )
                let correctedImage = self.scaleAndOrient(image: flipImage)
                
                // Place photo inside imageView.
//                print("set image")
                self.imageView.image = correctedImage
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension HomepageViewController: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss picker, returning to original root viewController.
        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                                        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // Extract chosen image.
        let originalImage: UIImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        self.srcImage = originalImage
        
        // Convert from UIImageOrientation to CGImagePropertyOrientation.
        guard let cgOrientation = CGImagePropertyOrientation(rawValue: UInt32(originalImage.imageOrientation.rawValue)) else {
            return
        }

        // Fire off request based on URL of chosen photo.
        guard let cgImage = originalImage.cgImage else {
            return
        }
        performVisionRequest(image: cgImage,
                             orientation: cgOrientation)
        
//        // Account for image orientation by transforming view.
//        let correctedImage = scaleAndOrient(image: self.tmpImage!)
//
//        // Place photo inside imageView.
//        imageView.image = correctedImage
        
        // Dismiss the picker to return to original view controller.
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UINavigationControllerDelegatee

extension HomepageViewController: UINavigationControllerDelegate {
    
}


//
//  ViewController.swift
//  ARkit-prototype
//
//  Created by Charlie G on 27/09/2017.
//  Copyright © 2017 Charlie G. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Vision
import Foundation
import CoreLocation

class ViewController: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    var requests = [VNRequest]()
    @IBOutlet weak var debugTextView: UITextView!
    //    var session = AVCaptureSession()
    let dispatchQueueML = DispatchQueue(label: "com.hw.dispatchqueueml") // A Serial Queue
    
    //Location
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        sceneView.autoenablesDefaultLighting = true
        
        // Create a new scene
//                let scene = SCNScene(named: "art.scnassets/ship.scn")!
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        let rectangleRequest = VNDetectRectanglesRequest(completionHandler: self.detectRectanglesHandler)
//        rectangleRequest.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop
        self.requests = [rectangleRequest]
        
        loopCoreMLUpdate()
        
        // Initialise location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // Get location coordinates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]

        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
    
        print("******** MY LOCATION ************")
        print(myLocation)
    }
    
    override func viewDidLayoutSubviews() {
        sceneView.layer.sublayers?[0].frame = sceneView.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
        
//        startRectanglesDetection()
    }
    
    
    
//    func startRectanglesDetection(){
//        let rectangleRequest = VNDetectRectanglesRequest(completionHandler: self.detectRectanglesHandler)
//        self.requests = [rectangleRequest]
//    }
    
    
    func loopCoreMLUpdate() {
        // Continuously run CoreML whenever it's ready. (Preventing 'hiccups' in Frame Rate)
        
        dispatchQueueML.async {
            // 1. Run Update.
            self.updateCoreML()
            
            // 2. Loop this function.
            self.loopCoreMLUpdate()
        }
        
    }
    
    
//
    func detectRectanglesHandler(request: VNRequest, error: Error?){
        guard let observations = request.results else {
            print("no result")
            return
        }
        
        let result = observations.map({$0 as? VNRectangleObservation})
        
        DispatchQueue.main.async {
            self.sceneView.layer.sublayers?.removeSubrange(1...)
            // self.sceneView.layer.sublayers?.removeSubrange(1...)
            print(result)
            print("--")
            
            for rectangle in result {
                
                guard let rect = rectangle else {
                    continue
                }
//                let convertedRect = self.convertFromCamera(rect.boundingBox)
                self.highlightRectangle(box: rect)
            }
        }
    }
    
//    enum RectangleCorners {
//        case topLeft(topLeft: SCNVector3, topRight: SCNVector3, bottomLeft: SCNVector3)
//        case topRight(topLeft: SCNVector3, topRight: SCNVector3, bottomRight: SCNVector3)
//        case bottomLeft(topLeft: SCNVector3, bottomLeft: SCNVector3, bottomRight: SCNVector3)
//        case bottomRight(topRight: SCNVector3, bottomLeft: SCNVector3, bottomRight: SCNVector3)
//    }
    
//    func getCorners(for rectangle: VNRectangleObservation, in sceneView: ARSCNView) -> (corners: RectangleCorners, anchor: ARPlaneAnchor)?{
//
//        let tl = sceneView.hitTest(convertFromCamera(rectangle.topLeft), types: .existingPlaneUsingExtent)
//        let tr = sceneView.hitTest(convertFromCamera(rectangle.topRight), types: .existingPlaneUsingExtent)
//        let bl = sceneView.hitTest(convertFromCamera(rectangle.bottomLeft), types: .existingPlaneUsingExtent)
//        let br = sceneView.hitTest(convertFromCamera(rectangle.bottomRight), types: .existingPlaneUsingExtent)
//
//        print("tl: \(tl.count) tr: \(tr.count) br: \(br.count) bl: \(bl.count)")
//
//        return nil
//    }
//
//    func convertFromCamera(_ point: CGPoint) -> CGPoint {
//        let orientation = UIApplication.shared.statusBarOrientation
//
//        let frame = sceneView.frame.size
//
//        switch orientation {
//        case .portrait, .unknown:
//            return CGPoint(x: point.y * frame.width, y: point.x * frame.height)
//        case .landscapeLeft:
//            return CGPoint(x: (1 - point.x) * frame.width, y: point.y * frame.height)
//        case .landscapeRight:
//            return CGPoint(x: point.x * frame.width, y: (1 - point.y) * frame.height)
//        case .portraitUpsideDown:
//            return CGPoint(x: (1 - point.y) * frame.width, y: (1 - point.x) * frame.height)
//        }
//    }
    
//    func convertFromCamera(_ rect: CGRect) -> CGRect {
//        let orientation = UIApplication.shared.statusBarOrientation
//        let x, y, w, h: CGFloat
//
//       let frame = sceneView.frame.size
//
//        switch orientation {
//        case .portrait, .unknown:
//            w = rect.height
//            h = rect.width
//            x = rect.origin.y
//            y = rect.origin.x
//        case .landscapeLeft:
//            w = rect.width
//            h = rect.height
//            x = 1 - rect.origin.x - w
//            y = rect.origin.y
//        case .landscapeRight:
//            w = rect.width
//            h = rect.height
//            x = rect.origin.x
//            y = 1 - rect.origin.y - h
//        case .portraitUpsideDown:
//            w = rect.height
//            h = rect.width
//            x = 1 - rect.origin.y - w
//            y = 1 - rect.origin.x - h
//        }
//
//        return CGRect(x: x * frame.width, y: y * frame.height, width: w * frame.width, height: h * frame.height)
//    }
    
    func highlightRectangle(box: VNRectangleObservation){
//
//        guard let cornersAndAnchor = getCorners(for: box, in: sceneView) else {
//            return
//        }
//
//        let corners = cornersAndAnchor.corners
//        print("**********")
//        print(corners)
//        print("**********")
        
        var toRect = CGRect()
        
        toRect.size.width = box.boundingBox.size.width * sceneView.frame.size.width
        toRect.size.height = box.boundingBox.size.height * sceneView.frame.size.height
        toRect.origin.y =  (sceneView.frame.size.height) - (sceneView.frame.size.height * box.boundingBox.origin.y )
        toRect.origin.y  = toRect.origin.y -  toRect.size.height
        toRect.origin.x =  box.boundingBox.origin.x * sceneView.frame.size.width
        
        let boxRect = box.boundingBox
        let rectCenter = CGPoint(x: boxRect.midX, y: boxRect.midY)
        let hitTestResults = sceneView.hitTest(rectCenter, types: [.existingPlaneUsingExtent, .featurePoint])
        
        print("*********")
//        print(hitTestResults[0].worldTransform) // raises error
        
        
        let outline = CALayer()
        //        outline.frame = CGRect(x: xCord, y: yCord, width: width, height: height)
        outline.frame = toRect
        outline.borderWidth = 5.0
        outline.borderColor = UIColor.red.cgColor
        
        //        imageView.layer.addSublayer(outline)
        sceneView.layer.addSublayer(outline)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            // Do any desired updates to SceneKit here.
        }
    }
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func updateCoreML() {
        ///////////////////////////
        // Get Camera Image as RGB
        let pixbuff : CVPixelBuffer? = (sceneView.session.currentFrame?.capturedImage)
        if pixbuff == nil { return }
        let ciImage = CIImage(cvPixelBuffer: pixbuff!)
        // Note: Not entirely sure if the ciImage is being interpreted as RGB, but for now it works with the Inception model.
        // Note2: Also uncertain if the pixelBuffer should be rotated before handing off to Vision (VNImageRequestHandler) - regardless, for now, it still works well with the Inception model.
        
        ///////////////////////////
        // Prepare CoreML/Vision Request
        let imageRequestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        // let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage!, orientation: myOrientation, options: [:]) // Alternatively; we can convert the above to an RGB CGImage and use that. Also UIInterfaceOrientation can inform orientation values.
        
        ///////////////////////////
        // Run Image Request
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
}



// **************************
// FIRST VERSION
// ***************************

////
////  ViewController.swift
////  ARkit-prototype
////
////  Created by Charlie G on 27/09/2017.
////  Copyright © 2017 Charlie G. All rights reserved.
////
//
//import UIKit
//import SceneKit
//import ARKit
//import Vision
//
//class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
//
//    @IBOutlet var sceneView: ARSCNView!
//    var requests = [VNRequest]()
////    var session = AVCaptureSession()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Set the view's delegate
//        sceneView.delegate = self
//
//        sceneView.session.delegate = self
//
//        // Show statistics such as fps and timing information
//        sceneView.showsStatistics = true
//
//        sceneView.autoenablesDefaultLighting = true
//
//        // Create a new scene
////        let scene = SCNScene(named: "art.scnassets/ship.scn")!
//        let scene = SCNScene()
//
//        // Set the scene to the view
//        sceneView.scene = scene
//
//    }
//
////    override func viewDidLayoutSubviews() {
////        sceneView.layer.sublayers?[0].frame = sceneView.bounds
////    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        // Create a session configuration
//        let configuration = ARWorldTrackingConfiguration()
//
//        // Run the view's session
//        sceneView.session.run(configuration)
//
//        startRectanglesDetection()
//    }
//
//
//
//    func startRectanglesDetection(){
//        let rectangleRequest = VNDetectRectanglesRequest(completionHandler: self.detectRectanglesHandler)
//        self.requests = [rectangleRequest]
//    }
//
//    func detectRectanglesHandler(request: VNRequest, error: Error?){
//        guard let observations = request.results else {
//            print("no result")
//            return
//        }
//
//        print("HEREEEEE ***********")
//
//        let result = observations.map({$0 as? VNRectangleObservation})
//
//        DispatchQueue.main.async {
//            self.sceneView.layer.sublayers?.removeSubrange(1...)
//            //            self.sceneView.layer.sublayers?.removeSubrange(1...)
//            for rectangle in result {
//
//                guard let rect = rectangle else {
//                    continue
//                }
//
//                self.highlightRectangle(box: rect)
//            }
//        }
//    }
//
//    func highlightRectangle(box: VNRectangleObservation){
//
//        var toRect = CGRect()
//
//        toRect.size.width = box.boundingBox.size.width * sceneView.frame.size.width
//        toRect.size.height = box.boundingBox.size.height * sceneView.frame.size.height
//        toRect.origin.y =  (sceneView.frame.size.height) - (sceneView.frame.size.height * box.boundingBox.origin.y )
//        toRect.origin.y  = toRect.origin.y -  toRect.size.height
//        toRect.origin.x =  box.boundingBox.origin.x * sceneView.frame.size.width
//
//
//        let outline = CALayer()
//        //        outline.frame = CGRect(x: xCord, y: yCord, width: width, height: height)
//        outline.frame = toRect
//        outline.borderWidth = 5.0
//        outline.borderColor = UIColor.red.cgColor
//
////        imageView.layer.addSublayer(outline)
//        sceneView.layer.addSublayer(outline)
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//
//        // Pause the view's session
//        sceneView.session.pause()
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Release any cached data, images, etc that aren't in use.
//    }
//
//    // MARK: - ARSCNViewDelegate
//
//
//    func session(_ session: ARSession, didFailWithError error: Error) {
//        // Present an error message to the user
//
//    }
//
//    func sessionWasInterrupted(_ session: ARSession) {
//        // Inform the user that the session has been interrupted, for example, by presenting an overlay
//
//    }
//
//    func sessionInterruptionEnded(_ session: ARSession) {
//        // Reset tracking and/or remove existing anchors if consistent tracking is required
//
//    }
//}


// **************************
// END OF FIRST VERSION
// ***************************


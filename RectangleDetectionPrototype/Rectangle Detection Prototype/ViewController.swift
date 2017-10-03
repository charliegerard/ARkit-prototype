//  ViewController.swift
//  Rectangle Detection Prototype based on Text Detection Starter Project
//
//  Created by Charlie Gerard on 09/27/17.

import UIKit
import AVFoundation
import Vision
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var sceneView: ARSCNView!
    var session = AVCaptureSession()
    var requests = [VNRequest]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        sceneView.delegate = self
//        sceneView.showsStatistics = true
//        
//        let scene = SCNScene()
//        
//        sceneView.scene = scene
//        
//        sceneView.autoenablesDefaultLighting = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        startLiveVideo()

//        startTextDetection()
        
        startRectanglesDetection()
        
//        let configuration = ARWorldTrackingConfiguration()
//        configuration.planeDetection = .horizontal
//        sceneView.session.run(configuration)
    }
    
    override func viewDidLayoutSubviews() {
        imageView.layer.sublayers?[0].frame = imageView.bounds
//        sceneView.layer.sublayers?[0].frame = sceneView.bounds
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func startLiveVideo() {
        //1
        session.sessionPreset = AVCaptureSession.Preset.photo
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        //2
        let deviceInput = try! AVCaptureDeviceInput(device: captureDevice!)
        let deviceOutput = AVCaptureVideoDataOutput()
        deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        deviceOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
        session.addInput(deviceInput)
        session.addOutput(deviceOutput)
        
        //3
        let imageLayer = AVCaptureVideoPreviewLayer(session: session)
        imageLayer.frame = imageView.bounds
//        imageLayer.frame = sceneView.bounds
        imageView.layer.addSublayer(imageLayer)
//        sceneView.layer.addSublayer(imageLayer)
        
        session.startRunning()
    }
    
    func startRectanglesDetection(){
        let rectangleRequest = VNDetectRectanglesRequest(completionHandler: self.detectRectanglesHandler)
        self.requests = [rectangleRequest]
    }
    
    func detectRectanglesHandler(request: VNRequest, error: Error?){
        guard let observations = request.results else {
            print("no result")
            return
        }

        let result = observations.map({$0 as? VNRectangleObservation})
        
        DispatchQueue.main.async {
            self.imageView.layer.sublayers?.removeSubrange(1...)
//            self.sceneView.layer.sublayers?.removeSubrange(1...)
            for rectangle in result {
                
                guard let rect = rectangle else {
                    continue
                }
                
                self.highlightRectangle(box: rect)
            }
        }
    
    }
    
    func highlightRectangle(box: VNRectangleObservation){
        
        var toRect = CGRect()
        toRect.size.width = box.boundingBox.size.width * imageView.frame.size.width
        toRect.size.height = box.boundingBox.size.height * imageView.frame.size.height
        toRect.origin.y =  (imageView.frame.size.height) - (imageView.frame.size.height * box.boundingBox.origin.y )
        toRect.origin.y  = toRect.origin.y -  toRect.size.height
        toRect.origin.x =  box.boundingBox.origin.x * imageView.frame.size.width

//        toRect.size.width = box.boundingBox.size.width * sceneView.frame.size.width
//        toRect.size.height = box.boundingBox.size.height * sceneView.frame.size.height
//        toRect.origin.y =  (sceneView.frame.size.height) - (sceneView.frame.size.height * box.boundingBox.origin.y )
//        toRect.origin.y  = toRect.origin.y -  toRect.size.height
//        toRect.origin.x =  box.boundingBox.origin.x * sceneView.frame.size.width
        
        
        let outline = CALayer()
//        outline.frame = CGRect(x: xCord, y: yCord, width: width, height: height)
        outline.frame = toRect
        outline.borderWidth = 5.0
        outline.borderColor = UIColor.red.cgColor
        
        imageView.layer.addSublayer(outline)
//        sceneView.layer.addSublayer(outline)
    }
    
    
    
    // ********************
    // OLD CODE
    // ********************
    
    
//    func startTextDetection() {
//        let textRequest = VNDetectTextRectanglesRequest(completionHandler: self.detectTextHandler)
//        textRequest.reportCharacterBoxes = true
//        self.requests = [textRequest]
//    }
    
    
//    func detectTextHandler(request: VNRequest, error: Error?) {
//        guard let observations = request.results else {
//            print("no result")
//            return
//        }
//
//        let result = observations.map({$0 as? VNTextObservation})
//
//        DispatchQueue.main.async() {
//            self.imageView.layer.sublayers?.removeSubrange(1...)
//            for region in result {
//                guard let rg = region else {
//                    continue
//                }
//
//                self.highlightWord(box: rg)
//
//                if let boxes = region?.characterBoxes {
//                    for characterBox in boxes {
//                        //                        self.highlightLetters(box: characterBox)
//                    }
//                }
//            }
//        }
//    }
    
//    func highlightWord(box: VNTextObservation) {
//        guard let boxes = box.characterBoxes else {
//            return
//        }
//        
//        var maxX: CGFloat = 9999.0
//        var minX: CGFloat = 0.0
//        var maxY: CGFloat = 9999.0
//        var minY: CGFloat = 0.0
//        
//        for char in boxes {
//            if char.bottomLeft.x < maxX {
//                maxX = char.bottomLeft.x
//            }
//            if char.bottomRight.x > minX {
//                minX = char.bottomRight.x
//            }
//            if char.bottomRight.y < maxY {
//                maxY = char.bottomRight.y
//            }
//            if char.topRight.y > minY {
//                minY = char.topRight.y
//            }
//        }
//        
//        let xCord = maxX * imageView.frame.size.width
//        let yCord = (1 - minY) * imageView.frame.size.height
//        let width = (minX - maxX) * imageView.frame.size.width
//        let height = (minY - maxY) * imageView.frame.size.height
//        
//        let outline = CALayer()
//        outline.frame = CGRect(x: xCord, y: yCord, width: width, height: height)
//        outline.borderWidth = 2.0
//        outline.borderColor = UIColor.red.cgColor
//        
//        imageView.layer.addSublayer(outline)
//    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        var requestOptions:[VNImageOption : Any] = [:]
        
        if let camData = CMGetAttachment(sampleBuffer, kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, nil) {
            requestOptions = [.cameraIntrinsics:camData]
        }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation(rawValue: 6)!, options: requestOptions)
        
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
}

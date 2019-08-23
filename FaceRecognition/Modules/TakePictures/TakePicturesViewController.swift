//
//  TakePicturesViewController.swift
//  FaceRecognition
//
//  Created by Su Van Ho on 22/8/19.
//  Copyright © 2019 Nimble. All rights reserved.
//

import UIKit
import AVKit
import Vision

final class TakePicturesViewController: CameraViewController {

    private var detectFaceRequests: [VNDetectFaceRectanglesRequest]?
    private lazy var sequenceRequestHandler = VNSequenceRequestHandler()
    private lazy var cacheRequests: [VNTrackObjectRequest] = []

    var detectionOverlayLayer: CALayer?
    var currentImage: CIImage?

    override func setupBeforeSessionRunning() {
        super.setupBeforeSessionRunning()
        prepareVisionRequest()
    }
}

// MARK: - Private Functions
extension TakePicturesViewController {
    private func prepareVisionRequest() {
        let detectFaceRequest: VNDetectFaceRectanglesRequest = VNDetectFaceRectanglesRequest { (request, error) in
            if error != nil {
                fatalError("FaceDetection error: \(error.debugDescription)")
            }
            guard let request = request as? VNDetectFaceRectanglesRequest,
                let results = request.results as? [VNFaceObservation] else {
                    return
            }
            DispatchQueue.main.async {
                self.updateRequests(with: results)
                self.detectionOverlayLayer?.sublayers = nil
                results.forEach({ self.drawFace(observation: $0) })
            }
        }
        detectFaceRequests = [detectFaceRequest]
        setupVisionDrawingLayers()
    }

    private func updateRequests(with observations: [VNFaceObservation]) {
        cacheRequests = observations.map({ VNTrackObjectRequest(detectedObjectObservation: $0) })
    }

    private func drawFace(observation: VNFaceObservation) {
        CATransaction.begin()
        CATransaction.setValue(NSNumber(value: true), forKey: kCATransactionDisableActions)
        let faceLayer = faceRectangleLayer()
        let faceRectanglePath = CGMutablePath()
        let displaySize = captureDeviceResolution
        let faceBounds = VNImageRectForNormalizedRect(observation.boundingBox, Int(displaySize.width), Int(displaySize.height))
        faceRectanglePath.addRect(faceBounds)
        faceLayer.path = faceRectanglePath
        detectionOverlayLayer?.addSublayer(faceLayer)
        if let image = currentImage?
            .oriented(exifOrientation)
            .cropped(toFace: observation)
            .toUIImage() {
            PhotoManager.shared.save(image: image)
        }
        updateLayerGeometry()
        CATransaction.commit()
    }

    private func setupVisionDrawingLayers() {
        let resolution = captureDeviceResolution
        let captureDeviceBounds = CGRect(x: 0,
                                         y: 0,
                                         width: resolution.width,
                                         height: resolution.height)
        let normalizedCenterPoint = CGPoint(x: 0.5, y: 0.5)
        guard let rootLayer = self.rootLayer else {
            fatalError(AppError.takePicture.localizedDescription)
        }
        let overlayLayer = CALayer()
        overlayLayer.name = "DetectionOverlay"
        overlayLayer.masksToBounds = true
        overlayLayer.anchorPoint = normalizedCenterPoint
        overlayLayer.bounds = captureDeviceBounds
        overlayLayer.position = CGPoint(x: rootLayer.bounds.midX, y: rootLayer.bounds.midY)

        rootLayer.addSublayer(overlayLayer)
        detectionOverlayLayer = overlayLayer

        updateLayerGeometry()
    }

    private func faceRectangleLayer() -> CAShapeLayer {
        let resolution = captureDeviceResolution
        let captureDeviceBounds = CGRect(x: 0,
                                         y: 0,
                                         width: resolution.width,
                                         height: resolution.height)
        let deviceCenterPoint = CGPoint(x: captureDeviceBounds.midX,
                                        y: captureDeviceBounds.midY)
        let normalizedCenterPoint = CGPoint(x: 0.5, y: 0.5)
        let faceRectangleShapeLayer = CAShapeLayer()
        faceRectangleShapeLayer.name = "FaceRectangleLayer"
        faceRectangleShapeLayer.bounds = captureDeviceBounds
        faceRectangleShapeLayer.anchorPoint = normalizedCenterPoint
        faceRectangleShapeLayer.position = deviceCenterPoint
        faceRectangleShapeLayer.fillColor = nil
        faceRectangleShapeLayer.strokeColor = UIColor.yellow.withAlphaComponent(0.7).cgColor
        faceRectangleShapeLayer.lineWidth = 5
        faceRectangleShapeLayer.shadowOpacity = 0.7
        faceRectangleShapeLayer.shadowRadius = 5
        return faceRectangleShapeLayer
    }

    private func updateLayerGeometry() {
        guard let overlayLayer = self.detectionOverlayLayer,
            let rootLayer = self.rootLayer,
            let previewLayer = self.previewLayer
            else {
                return
        }
        CATransaction.setValue(NSNumber(value: true), forKey: kCATransactionDisableActions)
        let videoPreviewRect = previewLayer.layerRectConverted(fromMetadataOutputRect: CGRect(x: 0, y: 0, width: 1, height: 1))
        var rotation: CGFloat
        var scaleX: CGFloat
        var scaleY: CGFloat
        switch UIDevice.current.orientation {
        case .portraitUpsideDown:
            rotation = 180
            scaleX = videoPreviewRect.width / captureDeviceResolution.width
            scaleY = videoPreviewRect.height / captureDeviceResolution.height

        case .landscapeLeft:
            rotation = 90
            scaleX = videoPreviewRect.height / captureDeviceResolution.width
            scaleY = scaleX

        case .landscapeRight:
            rotation = -90
            scaleX = videoPreviewRect.height / captureDeviceResolution.width
            scaleY = scaleX
        default:
            rotation = 0
            scaleX = videoPreviewRect.width / captureDeviceResolution.width
            scaleY = videoPreviewRect.height / captureDeviceResolution.height
        }
        var scaleXForPosition: CGFloat
        if position == .back {
            scaleXForPosition = -scaleX
        } else {
            scaleXForPosition = scaleX
        }
        let affineTransform = CGAffineTransform(rotationAngle: rotation.radians)
            .scaledBy(x: scaleXForPosition, y: -scaleY)
        overlayLayer.setAffineTransform(affineTransform)
        let rootLayerBounds = rootLayer.bounds
        overlayLayer.position = CGPoint(x: rootLayerBounds.midX, y: rootLayerBounds.midY)
    }
}

extension TakePicturesViewController {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        var options: [VNImageOption: Any] = [:]
        let cameraIntrinsicData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil)
        if cameraIntrinsicData != nil {
            options[VNImageOption.cameraIntrinsics] = cameraIntrinsicData
        }
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            fatalError("Failed to obtain a CVPixelBuffer for the current output frame.")
        }
        let eOrientation = exifOrientation
        if cacheRequests.isEmpty {
            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: eOrientation, options: options)
            currentImage = CIImage(cvPixelBuffer: pixelBuffer)
            do {
                guard let detectRequest = detectFaceRequests else { return }
                try imageRequestHandler.perform(detectRequest)
                return
            } catch {
                fatalError(error.localizedDescription)
            }
        }
        do {
            try sequenceRequestHandler.perform(cacheRequests, on: pixelBuffer, orientation: eOrientation)
        } catch {
            fatalError(error.localizedDescription)
        }

        var newCacheRequests: [VNTrackObjectRequest] = []
        for request in cacheRequests {
            guard let results = request.results as? [VNDetectedObjectObservation], let observation = results.first else {
                return
            }
            if !request.isLastFrame {
                if observation.confidence > 0.5 {
                    request.inputObservation = observation
                } else {
                    request.isLastFrame = true
                }
                newCacheRequests.append(request)
            }
            request.isLastFrame = true
        }
        cacheRequests = newCacheRequests
    }
}

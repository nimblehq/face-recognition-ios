//
//  CameraViewController.swift
//  FaceRecognition
//
//  Created by Su Van Ho on 22/8/19.
//  Copyright © 2019 Nimble. All rights reserved.
//

import UIKit
import AVKit

class CameraViewController: UIViewController {

    let backButton = UIButton(type: .system)
    let switchButton = UIButton(type: .system)

    // View for showing camera content
    let previewView = UIView(frame: UIScreen.main.bounds)
    var rootLayer: CALayer?

    // AVCapture variables
    var session: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var position: AVCaptureDevice.Position = .front

    var videoDataOutput: AVCaptureVideoDataOutput?
    var videoDataOutputQueue: DispatchQueue?

    var captureDevice: AVCaptureDevice?
    var captureDeviceResolution: CGSize = CGSize()

    var exifOrientation: CGImagePropertyOrientation {
        switch UIDevice.current.orientation {
        case .portraitUpsideDown:
            return .rightMirrored
        case .landscapeLeft:
            return .downMirrored
        case .landscapeRight:
            return .upMirrored
        default:
            return .leftMirrored
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }

    override func loadView() {
        super.loadView()
        setUpPreviewView()
        previewView.layer.frame = previewView.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        session = setUpAVCaptureSession()
        setupBeforeSessionRunning()
        session?.startRunning()
    }

    func setupBeforeSessionRunning() {}
}

// MARK: - SetUp
extension CameraViewController {
    private func setUpPreviewView() {
        previewView.backgroundColor = .white
        view.addSubview(previewView)

        view.addSubview(backButton)
        backButton.setImage(UIImage(named: "Close"), for: .normal)
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)

        backButton.snp.makeConstraints { make in
            make.size.equalTo(50)
            make.left.top.equalToSuperview().inset(16)
        }

        view.addSubview(switchButton)
        switchButton.setTitle("Switch Camera", for: .normal)
        switchButton.addTarget(self, action: #selector(switchCamera), for: .touchUpInside)

        switchButton.snp.makeConstraints { make in
            make.centerY.equalTo(backButton.snp.centerY)
            make.left.equalTo(backButton.snp.right).inset(-16)
        }
    }

    @objc private func back() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func switchCamera() {
        switch position {
        case .front:
            position = .back
        case .back:
            position = .front
        default: return
        }
        if let session = self.session {
            _ = try? setUpCamera(for: session, position: position)
        }
    }
}

// MARK: - SetUpAVCaptureSession
extension CameraViewController {
    private func setUpAVCaptureSession() -> AVCaptureSession? {
        let session = AVCaptureSession()
        do {
            let inputDevice = try setUpCamera(for: session, position: position)
            setUpVideoDataOutput(for: session)
            captureDevice = inputDevice.device
            captureDeviceResolution = inputDevice.resolution
            designatePreviewLayer(for: session)
            return session
        } catch {
            teardownAVCapture()
        }
        return nil
    }

    private func setUpCamera(for session: AVCaptureSession, position: AVCaptureDevice.Position) throws -> (device: AVCaptureDevice, resolution: CGSize) {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                                      mediaType: .video,
                                                                      position: position)
        guard let device = deviceDiscoverySession.devices.first, let deviceInput = try? AVCaptureDeviceInput(device: device) else {
            throw AppError.frontCamera
        }
        if let input = session.inputs.first {
            session.removeInput(input)
        }
        if session.canAddInput(deviceInput) {
            session.addInput(deviceInput)
        }
        if let highestResolution = highestResolution420Format(for: device) {
            try device.lockForConfiguration()
            device.activeFormat = highestResolution.format
            device.unlockForConfiguration()
            return (device, highestResolution.resolution)
        }
        throw AppError.frontCamera
    }

    private func setUpFrontCamera(for session: AVCaptureSession) throws -> (device: AVCaptureDevice, resolution: CGSize) {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                                      mediaType: .video,
                                                                      position: .front)
        guard let device = deviceDiscoverySession.devices.first, let deviceInput = try? AVCaptureDeviceInput(device: device) else {
            throw AppError.frontCamera
        }
        if session.canAddInput(deviceInput) {
            session.addInput(deviceInput)
        }
        if let highestResolution = highestResolution420Format(for: device) {
            try device.lockForConfiguration()
            device.activeFormat = highestResolution.format
            device.unlockForConfiguration()
            return (device, highestResolution.resolution)
        }
        throw AppError.frontCamera
    }

    private func highestResolution420Format(for device: AVCaptureDevice) -> (format: AVCaptureDevice.Format, resolution: CGSize)? {
        var highestResolutionFormat: AVCaptureDevice.Format? = nil
        var highestResolutionDimensions = CMVideoDimensions(width: 0, height: 0)
        for format in device.formats {
            let deviceFormat = format as AVCaptureDevice.Format
            let deviceFormatDescription = deviceFormat.formatDescription
            if CMFormatDescriptionGetMediaSubType(deviceFormatDescription) == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange {
                let candidateDimensions = CMVideoFormatDescriptionGetDimensions(deviceFormatDescription)
                if (highestResolutionFormat == nil) || (candidateDimensions.width > highestResolutionDimensions.width) {
                    highestResolutionFormat = deviceFormat
                    highestResolutionDimensions = candidateDimensions
                }
            }
        }
        guard highestResolutionFormat != nil else {
            return nil
        }
        let resolution = CGSize(width: CGFloat(highestResolutionDimensions.width), height: CGFloat(highestResolutionDimensions.height))
        return (highestResolutionFormat!, resolution)
    }

    private func setUpVideoDataOutput(for captureSession: AVCaptureSession) {
        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        let queue = DispatchQueue(label: "co.nimblehq.growth.FaceRecognition.queue")
        output.setSampleBufferDelegate(self, queue: queue)
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }
        output.connection(with: .video)?.isEnabled = true
        if let captureConnection = output.connection(with: AVMediaType.video) {
            if captureConnection.isCameraIntrinsicMatrixDeliverySupported {
                captureConnection.isCameraIntrinsicMatrixDeliveryEnabled = true
            }
        }
        videoDataOutput = output
        videoDataOutputQueue = queue
    }

    private func designatePreviewLayer(for session: AVCaptureSession) {
        let layer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer = layer
        layer.name = "CameraPreview"
        layer.backgroundColor = UIColor.black.cgColor
        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewView.layer.masksToBounds = true
        layer.frame = previewView.layer.bounds
        previewView.layer.addSublayer(layer)
        rootLayer = previewView.layer
    }

    private func teardownAVCapture() {
        self.videoDataOutput = nil
        self.videoDataOutputQueue = nil
        if let previewLayer = self.previewLayer {
            previewLayer.removeFromSuperlayer()
            self.previewLayer = nil
        }
    }
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {}

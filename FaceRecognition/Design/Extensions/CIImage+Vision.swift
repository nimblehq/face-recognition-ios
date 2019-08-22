//
//  CIImage+Vision.swift
//  FaceRecognition
//
//  Created by Su Van Ho on 22/8/19.
//  Copyright © 2019 Nimble. All rights reserved.
//

import UIKit
import CoreImage
import Vision

extension CIImage {
    func toUIImage() -> UIImage? {
        let context = CIContext(options: nil)
        guard let cgImage: CGImage = context.createCGImage(self, from: self.extent) else { return nil }
        let image: UIImage = UIImage(cgImage: cgImage)
        return image
    }

    func cropped(toFace face: VNFaceObservation) -> CIImage {
        let percentage: CGFloat = 0.5
        let width = face.boundingBox.width * CGFloat(extent.size.width)
        let height = face.boundingBox.height * CGFloat(extent.size.height)
        let x = face.boundingBox.origin.x * CGFloat(extent.size.width)
        let y = face.boundingBox.origin.y * CGFloat(extent.size.height)
        let rect = CGRect(x: x, y: y, width: width, height: height)
        let increasedRect = rect.insetBy(dx: width * -percentage, dy: height * -percentage)
        return cropped(to: increasedRect)
    }
}


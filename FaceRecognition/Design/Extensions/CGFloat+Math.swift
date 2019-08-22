//
//  CGFloat+Math.swift
//  FaceRecognition
//
//  Created by Su Van Ho on 22/8/19.
//  Copyright © 2019 Nimble. All rights reserved.
//

import UIKit

extension CGFloat {
    var radians: CGFloat {
        return CGFloat(Double(self) * Double.pi / 180.0)
    }
}

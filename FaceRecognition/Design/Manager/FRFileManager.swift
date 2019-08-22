//
//  FRFileManager.swift
//  FaceRecognition
//
//  Created by Su Van Ho on 22/8/19.
//  Copyright © 2019 Nimble. All rights reserved.
//

import UIKit
import CoreImage

final class FRFileManager {
    static let shared = FRFileManager()

    private let documentPath: URL = {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let url: URL = paths.first else { fatalError("File Path Error") }
        print("Document Path: " + url.path)
        return url
    }()

    func save(image: UIImage) throws {
        guard let data = image.pngData() else {
            throw AppError.fileManager
        }
        let fileURL = documentPath.appendingPathComponent("\(Date().timeIntervalSince1970)_image.png")
        try data.write(to: fileURL)
    }

    func remove() throws {
        let fileURL = documentPath
        try FileManager.default.removeItem(at: fileURL)
    }
}

//
//  ModelManager.swift
//  FaceRecognition
//
//  Created by Su Van Ho on 23/8/19.
//  Copyright © 2019 Nimble. All rights reserved.
//

import Foundation
import CoreML
import Vision

final class ModelManager {

    static let shared = ModelManager()

    let model: VNCoreMLModel? = try? VNCoreMLModel(for: ImageClassifier().model)

    func request(completion: @escaping (String) -> ()) -> VNCoreMLRequest {
        guard let model = self.model else { fatalError("Create ImageClassifier Error!!!") }
        return VNCoreMLRequest(model: model, completionHandler: { (request, error) in
            if error != nil {
                print(error.debugDescription)
            } else {
                guard let classifications = request.results as? [VNClassificationObservation],
                    let observation = classifications.first else {
                        return
                }
                if observation.confidence >= 0.7 {
                    completion("\(observation.identifier) - confidence: \(observation.confidence)")
                } else {
                    print("\(observation.identifier) - confidence: \(observation.confidence)")
                }
            }
        })
    }
}

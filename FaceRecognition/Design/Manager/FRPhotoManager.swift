//
//  FRPhotoManager.swift
//  FaceRecognition
//
//  Created by Su Van Ho on 22/8/19.
//  Copyright © 2019 Nimble. All rights reserved.
//

import Photos

final class FRPhotoManager {
    static let albumName = "co.nimblehq.growth.FaceRecognition.images"
    static let shared = FRPhotoManager()

    private var assetCollection: PHAssetCollection?

    init() {
        assetCollection = fetchAssetCollectionForAlbum()
    }
}

// MARK: - Public Functions
extension FRPhotoManager {
    func save(image: UIImage) {
        authorizationWithHandler { success in
            guard success, let collection = self.assetCollection else {
                 fatalError(AppError.photoManager.localizedDescription)
            }
            PHPhotoLibrary.shared().performChanges({
                let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                guard let placeholder = request.placeholderForCreatedAsset,
                    let changeRequest = PHAssetCollectionChangeRequest(for: collection) else {
                        fatalError(AppError.photoManager.localizedDescription)
                }
                let enumeration: NSArray = [placeholder]
                changeRequest.addAssets(enumeration)
            }, completionHandler: { (success, error) in
                if success {
                    print("Saved Image")
                } else {
                    fatalError(AppError.photoManager.localizedDescription)
                }
            })
        }
    }
}

// MARK: - Private Functions
extension FRPhotoManager {
    private func authorizationWithHandler(completion: @escaping ((Bool) -> Void)) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (_) in
                self.authorizationWithHandler(completion: completion)
            }
        case .authorized:
            createAlbumIfNeeded(completion: completion)
        default:
            completion(false)
        }
    }

    private func createAlbumIfNeeded(completion: @escaping ((Bool) -> Void)) {
        if let collection = fetchAssetCollectionForAlbum() {
            assetCollection = collection
        } else {
            PHPhotoLibrary.shared().performChanges({
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: FRPhotoManager.albumName)
            }, completionHandler: { (success, error) in
                if success {
                    self.assetCollection = self.fetchAssetCollectionForAlbum()
                } else {
                    fatalError(AppError.photoManager.localizedDescription)
                }
                completion(success)
            })
        }
    }

    private func fetchAssetCollectionForAlbum() -> PHAssetCollection? {
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "title = %@", FRPhotoManager.albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: options)
        return collection.firstObject
    }
}

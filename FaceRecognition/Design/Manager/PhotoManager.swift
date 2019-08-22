//
//  PhotoManager.swift
//  FaceRecognition
//
//  Created by Su Van Ho on 22/8/19.
//  Copyright © 2019 Nimble. All rights reserved.
//

import Photos

final class PhotoManager {
    static let albumName = "co.nimblehq.growth.FaceRecognition.album"
    static let shared = PhotoManager()

    private var assetCollection: PHAssetCollection?

    init() {
        assetCollection = fetchAssetCollectionForAlbum()
    }

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
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: PhotoManager.albumName)
            }, completionHandler: { (success, error) in
                if success {
                    self.assetCollection = self.fetchAssetCollectionForAlbum()
                } else {
                    fatalError("Unable create Album")
                }
                completion(success)
            })
        }
    }

    private func fetchAssetCollectionForAlbum() -> PHAssetCollection? {
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "title = %@", PhotoManager.albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: options)
        return collection.firstObject
    }

    func save(image: UIImage) {
        authorizationWithHandler { (success) in
            guard success, let collection = self.assetCollection else {
                fatalError("Error To Save Image")
            }

            PHPhotoLibrary.shared().performChanges({
                let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                guard let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset,
                    let albumChangeRequest = PHAssetCollectionChangeRequest(for: collection) else {
                        fatalError("PHAsset Error")
                }
                let enumeration: NSArray = [assetPlaceHolder]
                albumChangeRequest.addAssets(enumeration)
            }, completionHandler: { (success, error) in
                if success {
                    print("Saved Image")
                } else {
                    fatalError("Unable Save Image")
                }
            })
        }
    }
}


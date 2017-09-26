//
//  MainViewModel.swift
//  SwipeAnimationPractice
//
//  Created by Xinyuan Wang on 8/25/17.
//  Copyright © 2017Xinyuan Wang. All rights reserved.
//

import Foundation
import Photos

class SimpleImageManager: NSObject{
    let identifier = "SimpleImageManagerQueue"
    static let shared = SimpleImageManager()
    typealias Index = Int
    
    let queue: DispatchQueue
    var fetchOptions = PHFetchOptions()
    var imageRequestOptions = PHImageRequestOptions()
    
    private var collections: PHFetchResult<PHAssetCollection>?
    
    var count = 0;
    
    override init() {
        queue = DispatchQueue(label: identifier)
        fetchOptions.includeAssetSourceTypes = .typeUserLibrary
        
        imageRequestOptions.deliveryMode = .highQualityFormat
        imageRequestOptions.isSynchronous = false
        imageRequestOptions.resizeMode = .fast
        imageRequestOptions.isNetworkAccessAllowed = false
        imageRequestOptions.version = .current
        super.init()
        self.start()
    }
    
    func fetchCollection(at index: Index) -> PHAssetCollection? {
        guard index < self.count else { return nil}
        return self.collections?.object(at: index)
    }
    
    func start() {
        guard PHPhotoLibrary.authorizationStatus() == .authorized else {
            PHPhotoLibrary.requestAuthorization({ (status) in
            guard status == .authorized else { return }
            self.start()
        }); return }
        self.fetchOptions.includeAssetSourceTypes = .typeUserLibrary
        fetchOptions.predicate = NSPredicate(format: "estimatedAssetCount > 0")
        fetchOptions.includeAllBurstAssets = false
        self.collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: self.fetchOptions)
        self.count = self.collections?.count ?? 0
    }
}

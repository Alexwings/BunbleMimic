//
//  SimpleImage.swift
//  SwipeAnimationPractice
//
//  Created by Xinyuan Wang on 8/27/17.
//  Copyright © 2017 Xinyuan Wang. All rights reserved.
//

import Foundation
import UIKit
import Photos

class SimpleImage: NSObject {
    
    private let asset: PHAsset
    
    let size: CGSize
    
    let lastModificationDate: Date
    
    lazy var image: UIImage? = { [unowned self] in
        let manager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.isSynchronous = true
        //request image
        _ = manager.requestImage(for: self.asset, targetSize: self.size, contentMode: .aspectFill, options: requestOptions, resultHandler: { (img, info) in
            if let error = info?[PHImageErrorKey] as? NSError {
                print("Error: \(error.description)")
                return
            }
            self.image = img
        })
        return nil
    }()
    
    lazy var thumbnail: UIImage? = { [unowned self] in
        let manager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.deliveryMode = .fastFormat
        requestOptions.isSynchronous = true
        _ = manager.requestImage(for: self.asset, targetSize: GlobalVariables.thumbnailSize, contentMode: .aspectFill, options: requestOptions, resultHandler: { (img, info) in
            guard info?[PHImageErrorKey] == nil else {
                let error = info![PHImageErrorKey]
                print("Error: \(error.debugDescription)"); return
            }
            self.thumbnail = img ?? #imageLiteral(resourceName: "placeholder")
        })
        return #imageLiteral(resourceName: "placeholder")
    }()
    
    init(asset a:PHAsset, size: CGSize) {
        asset = a
        self.size = size
        self.lastModificationDate = a.modificationDate ?? a.creationDate ?? Date()
        super.init()
    }
}

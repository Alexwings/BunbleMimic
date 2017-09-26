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
    
    let lastModificationDate: Date
    
    var image: UIImage = #imageLiteral(resourceName: "placeholder")
    
    var imageLoaded: Bool = false
    
    init(asset a:PHAsset) {
        asset = a
        self.lastModificationDate = a.modificationDate ?? a.creationDate ?? Date()
        super.init()
        self.load(for: a)
    }
    
    internal func load(for asset: PHAsset) {
        self.imageLoaded = false
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = true
        options.version = .current
        options.resizeMode = .exact
        let size = CGSize(width: asset.pixelWidth / 2, height: asset.pixelHeight / 2)
        PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options) { (image, info) in
            if let error = info?[PHImageErrorKey] as? NSError {
                print(error.description)
                return
            }
            guard let img = image else { return }
            self.image = img
            self.imageLoaded = true
        }
            
    }
}

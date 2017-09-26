//
//  CardViewModel.swift
//  commonPractice
//
//  Created by Xinyuan's on 8/4/17.
//  Copyright © 2017 Xinyuan Wang. All rights reserved.
//

import Foundation
import UIKit
import Photos

class CardViewModel: NSObject {
    //MARK: public property
    var count: Int {
        didSet {
            if count > dataSource.count {
                count = oldValue
            }
        }
    }
    
    var creationDate: Date?
    
    var title: String?
    
    weak var managedView: CardView?
    
    @objc dynamic var observable: MainViewController
    
    //MARK: private property
    private var collection: PHAssetCollection {
        didSet {
            let options = PHFetchOptions()
            options.includeAssetSourceTypes = .typeUserLibrary
            options.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
            self.creationDate = collection.startDate
            self.title = collection.localizedTitle
            self.dataSource = PHAsset.fetchAssets(in: collection, options: options)
        }
    }
    private var dataSource: PHFetchResult<PHAsset> {
        didSet {
            if let view = self.managedView {
                view.reloadData()
            }
        }
    }
    
    private var observation: NSKeyValueObservation?

    
    init(with collection:PHAssetCollection, from controller: MainViewController) {
        self.collection = collection
        self.observable = controller
        let options = PHFetchOptions()
        options.includeAssetSourceTypes = .typeUserLibrary
        options.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        self.dataSource = PHAsset.fetchAssets(in: collection, options: options)
        count = dataSource.count
        self.creationDate = collection.startDate
        self.title = collection.localizedTitle
        super.init()
        observation = observe(\CardViewModel.observable.currentDisplayView) { (observed, change) in
            guard let newCard = observed.observable.currentDisplayView else { return }
            if newCard.model == self {
                self.count = self.dataSource.count
            }else {
                if let collection = SimpleImageManager.shared.fetchCollection(at: observed.observable.backAlbumIndex){
                    self.collection = collection
                }
                self.count = 3
            }
            newCard.reloadData()
        }
    }
    
    func updateDataSource(with collection: PHAssetCollection?){
        guard let collection = collection else { return }
        self.collection = collection
    }
}

extension CardViewModel: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return self.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellTypes.imageCell.rawValue, for: indexPath)
        if let cell = cell as? CardViewImageCell {
            cell.imageView.image = #imageLiteral(resourceName: "placeholder")
            let simage = self.dataSource[indexPath.item]
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isSynchronous = true
            _ = PHImageManager.default().requestImage(for: simage, targetSize: cell.imageView.bounds.size, contentMode: .aspectFit, options: options, resultHandler: { (image, info) in
                guard let img = image else { return }
                if let error = info?[PHImageErrorKey] as? NSError {
                    print("Error when retrieve image from asset: \(error.description)")
                    return
                }
                cell.imageView.image = img
            })
        }
        return cell
    }
}
extension UICollectionViewFlowLayout {
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}

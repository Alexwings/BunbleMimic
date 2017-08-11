//
//  CardViewModel.swift
//  commonPractice
//
//  Created by Xinyuan's on 8/4/17.
//  Copyright © 2017 Xinyuan Wang. All rights reserved.
//

import Foundation
import UIKit

class CardViewModel: NSObject {
    
    var dataSource: [Data]
    
    var infoViewIndex: Int {
        get {
            return dataSource.count
        }
    }
    
    init(with dataSource:[Data]) {
        self.dataSource = dataSource
        super.init()
    }
    convenience override init() {
        let ds = CardViewModel.fetchImage()
        self.init(with: ds)
    }
    
    //MARK: Update data methods
    class func fetchImage() -> [Data] {
        //temperary implememntation
        let paths = Bundle.main.paths(forResourcesOfType: "jpg", inDirectory: "testImage")
        var results: [Data] = []
        for p in paths where ((try? Data(contentsOf: URL(fileURLWithPath: p))) != nil) {
            let data = try! Data(contentsOf: URL(fileURLWithPath: p))
            results.append(data)
        }
        return results
    }
}

extension CardViewModel: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return self.dataSource.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellTypes.imageCell.rawValue, for: indexPath)
        if let cell = cell as? CardViewImageCell {
            let data = self.dataSource[indexPath.item]
            let img = UIImage(data: data)
            cell.imageView.image = img
        }
        return cell
    }
}

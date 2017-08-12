//
//  CardView.swift
//  commonPractice
//
//  Created by Xinyuan's on 8/2/17.
//  Copyright © 2017 Xinyuan Wang. All rights reserved.
//

import UIKit

class BaseView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    internal func setupViews() {}
}

class CardView: BaseView {
    
    override func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        layer.cornerRadius = GlobalVariables.cardCornerRadius
        clipsToBounds = true
        addGestureRecognizer(panGesture)
        addGestureRecognizer(tapGestrue)
        tapGestrue.require(toFail: doubleTap)
        
        collectionView.backgroundColor = UIColor.clear
        addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        collectionView.addSubview(infoBackView)
        infoBackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        infoBackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        infoBackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        infoBackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        infoBackView.isHidden = true
        
        addSubview(infoView)
        infoView.headerStack.addGestureRecognizer(doubleTap)
        infoView.trailingAnchor.constraint(equalTo: trailingAnchor,constant: GlobalVariables.CardViewIntervals.right.rawValue).isActive = true
        infoView.leadingAnchor.constraint(equalTo: leadingAnchor,constant: GlobalVariables.CardViewIntervals.left.rawValue).isActive = true
        infoView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: GlobalVariables.CardViewIntervals.right.rawValue).isActive = true
        infoHeightConstraint = infoView.heightAnchor.constraint(equalToConstant: GlobalVariables.cardInfoHeaderHeight)
        infoHeightConstraint?.isActive = true
        
        doubleTap.addTarget(self, action: #selector(enableTextField(sender:)))
        
    }
    
    //MARK:constraints
    
    var infoHeightConstraint: NSLayoutConstraint?
    
    //MARK: action methods
    @objc func enableTextField(sender: UITapGestureRecognizer) {
        guard sender.numberOfTapsRequired == 2 else { return }
        infoView.albumName.isEnabled = !infoView.albumName.isEnabled
        if infoView.albumName.isEnabled {
            infoView.albumName.becomeFirstResponder()
        }
    }
    
    //MARK: views
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collection.backgroundColor = UIColor.clear
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.register(CardViewImageCell.self, forCellWithReuseIdentifier: "imageCell")
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        collection.isPagingEnabled = true
        collection.bounces = false
        return collection
    }()
    
    var panGesture: UIPanGestureRecognizer = {
        let pg = UIPanGestureRecognizer()
        pg.minimumNumberOfTouches = 1
        pg.maximumNumberOfTouches = 1
        return pg
    }()
    
    var tapGestrue: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 1
        return tap
    }()
    
    var doubleTap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 2
        return tap
    }()
    
    let infoView: CardInfoView = {
        let view = CardInfoView(frame: .zero)
        view.layer.cornerRadius = GlobalVariables.cardCornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let infoBackView: UIView = {
        let v = UIView(frame: .zero)
        v.backgroundColor = UIColor.darkGray
        v.alpha = 0
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
}

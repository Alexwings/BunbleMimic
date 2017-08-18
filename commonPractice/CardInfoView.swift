//
//  CardInfoView.swift
//  SwipeAnimationPractice
//
//  Created by Xinyuan Wang on 8/11/17.
//  Copyright © 2017 Xinyuan Wang. All rights reserved.
//

import UIKit

class CardInfoView: BaseView {
    let albumName: UITextField = {
        let txt = UITextField(frame: .zero)
        txt.textAlignment = .center
        txt.text = "Hello World!"
        txt.isEnabled = false
        txt.translatesAutoresizingMaskIntoConstraints = false
        return txt
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel(frame: .zero)
        let dfmt = DateFormatter()
        dfmt.dateFormat = "yyyy-MM-dd"
        label.text = dfmt.string(from: Date())
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let doubleTapGesture: UITapGestureRecognizer = {
        let dtp = UITapGestureRecognizer()
        dtp.numberOfTapsRequired = 2
        return dtp
    }()
    
    let singleTapGuesture: UITapGestureRecognizer = {
        let stp = UITapGestureRecognizer()
        stp.numberOfTapsRequired = 1
        return stp
    }()
    
    var doubleTap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 2
        return tap
    }()
    
    var headerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillProportionally
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    override func setupViews() {
        backgroundColor = UIColor.lightGray
        addSubview(headerStack)
        headerStack.addArrangedSubview(albumName)
        headerStack.addArrangedSubview(timeLabel)
        headerStack.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        headerStack.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        headerStack.topAnchor.constraint(equalTo: topAnchor).isActive = true
        headerStack.heightAnchor.constraint(equalToConstant: GlobalVariables.cardInfoHeaderHeight).isActive = true
        
        addGestureRecognizer(singleTapGuesture)
        singleTapGuesture.require(toFail: doubleTap)
        headerStack.addGestureRecognizer(doubleTap)
    }
}

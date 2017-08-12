//
//  CardInfoView.swift
//  SwipeAnimationPractice
//
//  Created by Xinyuan Wang on 8/11/17.
//  Copyright © 2017 Xinyuan Wang. All rights reserved.
//

import UIKit

class CardInfoView: BaseView {
    
    let table: UITableView = {
        let t = UITableView(frame: .zero)
        t.allowsSelection = false
        return t
    }()
    
    override func setupViews() {
        backgroundColor = UIColor.clear
        addSubview(table)
        table.topAnchor.constraint(equalTo: topAnchor).isActive = true
        table.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        table.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        table.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        table.dataSource =
    }
}

class CardInfoModel: NSObject {
    convenience init(
}

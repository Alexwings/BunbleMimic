//
//  GlobalVariables.swift
//  commonPractice
//
//  Created by Xinyuan's on 8/8/17.
//  Copyright © 2017 Xinyuan Wang. All rights reserved.
//

import Foundation
import UIKit

struct GlobalVariables {
    
    enum CardViewIntervals: CGFloat {
        case top = 40.0, left = 5.0, right = -5.0, bottom = -30
    }
    
    static let dismissLineFactor: CGFloat = (1.0 / 8.0)
    static let cardCornerRadius: CGFloat = 30
    static let cardInfoHeaderHeight: CGFloat = 80
    static let dismissVelocity: CGFloat = 3000
    static let virticalVelocity: CGFloat = 2000
}

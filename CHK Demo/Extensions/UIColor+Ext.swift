//
//  UIColor+Ext.swift
//  CHK Demo
//
//  Created by Dan Tran Thanh  on 16/08/2021.
//

import UIKit
extension UIColor {
    static func mainColor() -> UIColor {
        return .blue
    }
    
    static func titleColor() -> UIColor {
        return .black
    }
    
    static func descColor() -> UIColor {
        return .gray
    }
    
    static func sellPriceColor() -> UIColor {
        return .red
    }
    
    static func buyPriceColor() -> UIColor {
        return .green
    }
    
    static func random() -> UIColor {
        return UIColor(red:   .random(),
                       green: .random(),
                       blue:  .random(),
                       alpha: 1.0)
    }
}
public extension CGFloat {
    
    func map(from: ClosedRange<CGFloat>, to: ClosedRange<CGFloat>) -> CGFloat {
        return ((self - from.lowerBound) / (from.upperBound - from.lowerBound)) * (to.upperBound - to.lowerBound) + to.lowerBound
    }
    
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

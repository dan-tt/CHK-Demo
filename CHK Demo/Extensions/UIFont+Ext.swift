//
//  UIFont+Ext.swift
//  CHK Demo
//
//  Created by Dan Tran Thanh  on 16/08/2021.
//

import UIKit
extension UIFont {
    static func titleFont() -> UIFont {
        return UIFont.systemFont(ofSize: 14)
    }
    
    static func descFont() -> UIFont {
        return UIFont.systemFont(ofSize: 16)
    }
    
    static func sellPriceFont() -> UIFont {
        return UIFont.systemFont(ofSize: 16)
    }
    
    static func buyPriceFont() -> UIFont {
        return UIFont.systemFont(ofSize: 14)
    }
}

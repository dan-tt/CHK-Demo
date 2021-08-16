//
//  Defines.swift
//  CHK Demo
//
//  Created by Dan Tran Thanh  on 16/08/2021.
//

import Foundation
import UIKit

struct Production {
    static var IS_DEV: Bool = true
    static var BASE_URL: String {
        get {
            return "https://www.coinhako.com/api/v3"
        }
    }
}

// MARK: - ScreenSize

struct ScreenSize {
    static let SCREEN_WIDTH             = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT            = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH        = max(SCREEN_WIDTH, SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH        = min(SCREEN_WIDTH, SCREEN_HEIGHT)
    
    static let NAVIGATION_BAR_HEIGHT: CGFloat = 44
    static let NAVIGATION_HEIGHT_FULL: CGFloat = NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT
    static let TABBAR_HEIGHT: CGFloat = 49
    
    static let STATUS_BAR_HEIGHT: CGFloat = {
        var height: CGFloat = 0
        if #available(iOS 13.0, *) {
            height = UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            height = UIApplication.shared.statusBarFrame.height
        }
        return height
    }()
    
    static let BOTTOM_PADDING: CGFloat = {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        } else {
            return 0
        }
    }()
    
    static let BORDER_WIDTH: CGFloat = 1/UIScreen.main.scale
}

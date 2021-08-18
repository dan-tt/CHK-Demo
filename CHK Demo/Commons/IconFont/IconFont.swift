//
//  IconFont.swift
//  CHK Demo
//
//  Created by Dan Tran Thanh  on 16/08/2021.
//

import UIKit
import JustIconFont

enum IconFont: String {
    case ic_back = "\u{EAC9}"
    case ic_coin_default = "\u{EF4B}"
    case ic_loading = "\u{EC80}"
    case ic_no_data = "\u{EEFD}"
    case ic_no_network = "\u{EEC3}"
    case ic_search = "\u{ED1B}"
}

extension IconFont: IconFontType, CaseIterable {
    public var name: String {
        return "Icofont"
    }
    
    public var filePath: String? {
        return Bundle.main.path(forResource: "Icofont", ofType: "ttf")
    }
    
    public var unicode: String {
        return self.rawValue
    }
}

struct FontSize {
    static let h0: CGFloat = 40
    static let h1: CGFloat = 30
    static let h2: CGFloat = 25
    static let h3: CGFloat = 22
    static let h4: CGFloat = 20
    static let h5: CGFloat = 18
    static let h6: CGFloat = 16
    static let h7: CGFloat = 14
    static let h8: CGFloat = 12
    static let h9: CGFloat = 10
}

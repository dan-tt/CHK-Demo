//
//  UIView+Ext.swift
//  CHK Demo
//
//  Created by Dan Tran Thanh  on 16/08/2021.
//

import UIKit
import PureLayout

extension UIView {
    // MARK: - Corners radius
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        if #available(iOS 11.0, *) {
            clipsToBounds = true
            layer.cornerRadius = radius
            layer.maskedCorners = CACornerMask(rawValue: corners.rawValue)
        } else {
            DispatchQueue.main.async {
                let path = UIBezierPath(roundedRect: self.bounds,
                                        byRoundingCorners: corners,
                                        cornerRadii: CGSize(width: radius, height: radius))
                let maskLayer = CAShapeLayer()
                maskLayer.frame = self.bounds
                maskLayer.path = path.cgPath
                self.layer.mask = maskLayer
            }
        }
    }
    
    // MARK:- CORNER RADIUS
    func makeCorner(radius: CGFloat = 6) {
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
    }
    
    // MARK:- CORNER RADIUS
    func makeBorder(color: UIColor = .lightGray, width : CGFloat = ScreenSize.BORDER_WIDTH) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = width
    }
    
    // MARK: - Shadow
    
    func makeShadow() {
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.shadowRadius = 5
        self.layer.masksToBounds = false
    }
}

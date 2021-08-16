//
//  UIView+Ext.swift
//  CHK Demo
//
//  Created by Dan Tran Thanh  on 16/08/2021.
//

import UIKit
import PureLayout

extension UIView {
    /** This is the function to get subViews of a view of a particular type*/
    func subViews<T : UIView>(type : T.Type) -> [T]{
        var all = [T]()
        for view in self.subviews {
            if let aView = view as? T{
                all.append(aView)
            }
        }
        return all
    }
    
    
    /** This is a function to get subViews of a particular type from view recursively. It would look recursively in all subviews and return back the subviews of the type T */
    func allSubViewsOf<T : UIView>(type : T.Type) -> [T]{
        var all = [T]()
        func getSubview(view: UIView) {
            if let aView = view as? T{
                all.append(aView)
            }
            guard view.subviews.count>0 else { return }
            view.subviews.forEach{ getSubview(view: $0) }
        }
        getSubview(view: self)
        return all
    }
    
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
    
    // MARK: - Make Animation
    /// Rotate
    func startRotate() {
        let key = "rotate"
        if (layer.animation(forKey: key) != nil) {
            layer.removeAnimation(forKey: key)
        }
        let anim : CABasicAnimation = CABasicAnimation(keyPath: "transform")
        anim.fromValue = NSValue.init(caTransform3D: CATransform3DIdentity)
        anim.toValue = NSValue.init(caTransform3D: CATransform3DMakeRotation(.pi / 2, 0.0, 0.0, 1.0))
        anim.duration = 0.25
        anim.isCumulative = true
        anim.repeatCount = MAXFLOAT
        layer.add(anim, forKey: "rotate")
    }
    
    func stopRotate() {
        layer.removeAnimation(forKey: "rotate")
    }
}

//
//  EmptyDataConfig.swift
//  CHK Demo
//
//  Created by Dan Tran Thanh  on 16/08/2021.
//

import UIKit

enum EmptyDataType: String {
    case Base
}

struct EmptyDataConfig {
    weak var controller: BaseVC?
    
    init(controller: BaseVC) {
        self.controller = controller
    }
    
    var titleString: NSAttributedString? {
        return nil
    }
    
    var detailString: NSAttributedString? {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.titleFont(),
            .foregroundColor: UIColor.titleColor()
        ]
        if controller?.showLoading ?? false {
            return NSAttributedString(string: "Loading..", attributes: attributes)
        }
        
        if controller?.showNoNetwork ?? false {
            return NSAttributedString(string: "not connect", attributes: attributes)
        }
        
        if controller?.showNoData ?? false{
            switch controller?.emptyDataType {
            default:
                return NSAttributedString(string: "No data", attributes: attributes)
            }
        }
        
        return nil
    }
    
    var image: UIImage? {
        if controller?.showLoading ?? false {
            return UIImage.iconFont(IconFont.ic_loading, fontSize: FontSize.h0, color: UIColor.lightGray)
        }
        
        if controller?.showNoData ?? false {
            return UIImage.iconFont(IconFont.ic_no_data, fontSize: FontSize.h0, color: UIColor.lightGray)
        }
        
        if controller?.showNoNetwork ?? false {
            return UIImage.iconFont(IconFont.ic_no_network, fontSize: FontSize.h0, color: UIColor.lightGray)
        }
        
        return nil
    }
    
    var imageAnimation: CAAnimation? {
        let animation = CABasicAnimation.init(keyPath: "transform")
        animation.fromValue = NSValue.init(caTransform3D: CATransform3DIdentity)
        animation.toValue = NSValue.init(caTransform3D: CATransform3DMakeRotation(.pi/2, 0.0, 0.0, 1.0))
        animation.duration = 0.25
        animation.isCumulative = true
        animation.repeatCount = MAXFLOAT
        
        return animation;
    }
    
    func buttonTitle(_ state: UIControl.State) -> NSAttributedString? {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.titleFont(),
            .foregroundColor: UIColor.titleColor()
        ]
        
        if !(controller?.showLoading ?? false) {
            switch controller?.emptyDataType {
            default:
                return NSAttributedString(string: "Retry", attributes: attributes)
                
            }
        }
        
        return nil
    }
    
    func buttonBackgroundImage(_ state: UIControl.State) -> UIImage? {
        return nil
    }
    
    var backgroundColor: UIColor? {
        return .clear
    }
    
    var verticalOffset: CGFloat {
        switch controller?.emptyDataType {
        default:
            return ScreenSize.LEADING
        }
    }
    
    var spaceHeight: CGFloat {
        return 0
    }
    
    var customView: UIView? {
        switch controller?.emptyDataType {
        default:
            let v = ShimmerView(type: .normal, frame: controller?.view.frame ?? .zero)
            return (controller?.showLoading ?? false) ? v : nil
        }
    }
}

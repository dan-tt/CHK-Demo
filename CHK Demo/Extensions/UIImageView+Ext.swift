//
//  UIImageView+Ext.swift
//  CHK Demo
//
//  Created by Dan Tran Thanh  on 16/08/2021.
//

import UIKit
import SDWebImage

extension UIImageView {
    func setImage(with url: URL?, defaultImage: UIImage?) {
        self.sd_setImage(with: url, placeholderImage: defaultImage, options: [.avoidAutoSetImage]) { [weak self](image, error, cacheType, URL) in
            guard let self = self else { return }
            if image != nil, error == nil, url == URL {
                switch cacheType {
                case .memory, .disk:
                    self.image = image
                default:
                    UIView.transition(with: self, duration: 0.25, options: .transitionCrossDissolve, animations: {
                        self.image = image
                    }) { (finished) in

                    }
                }
            }
        }
    }
}


//
//  ShimmerView.swift
//  CHK Demo
//
//  Created by Dan Tran Thanh  on 17/08/2021.
//

import UIKit
import Shimmer

enum ShimmerType: Int {
    case none
    case normal
}

class ShimmerView : FBShimmeringView {
    private var type : ShimmerType?
    init(type: ShimmerType, frame: CGRect) {
        self.type = type
        super.init(frame: frame)
        self.backgroundColor = .white
        self.isShimmering = true
        self.shimmeringBeginFadeDuration = 0.3
        self.shimmeringOpacity = 1
        self.shimmeringAnimationOpacity = 0.3
        self.containView.frame = frame
        self.contentView = containView
        self.addSubView(height: 60, top: 40, space: 30, items: 10)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var containView: UIView = {
        let v = UIView()
        return v
    }()
    
    // MARK: - Screen

    private func addSubView(height: CGFloat, top: CGFloat, space: CGFloat, items: Int) {
        var itemPrevious: UIView?
        
        for _ in 0...items {
            let sv = UILabel()
            sv.backgroundColor = .gray200Color()
            sv.makeCorner()
            containView.addSubview(sv)
            
            if itemPrevious == nil {
                sv.autoPinEdge(toSuperviewEdge: .top, withInset: top)
            } else {
                sv.autoPinEdge(.top, to: .bottom, of: itemPrevious!, withOffset: space)
            }
            
            sv.autoPinEdge(toSuperviewEdge: .leading, withInset: ScreenSize.LEADING)
            sv.autoPinEdge(toSuperviewEdge: .trailing, withInset: ScreenSize.LEADING)
            sv.autoSetDimension(.height, toSize: height)
            
            itemPrevious = sv
        }
    }
}

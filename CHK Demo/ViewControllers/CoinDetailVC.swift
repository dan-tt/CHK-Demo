//
//  CoinDetailVC.swift
//  CHK Demo
//
//  Created by Dan Tran Thanh  on 18/08/2021.
//

import UIKit
import RxSwift

class CoinDetailVC: BaseVC {
    
    lazy var btnBack : UIButton = {
        let v = UIButton()
        v.iconFont(IconFont.ic_back, fontSize: FontSize.h0, color: .black, for: .normal)
        v.iconFont(IconFont.ic_back, fontSize: FontSize.h0, color: .lightGray, for: .highlighted)
        v.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        v.rx.tap.bind { [unowned self] in
            self.dismiss()
        }.disposed(by: disposeBag)
        return v
    }()
    
    lazy var imv : UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFit
        return v
    }()
    
    lazy var vInfo: UIView = {
        let v = UIView()
        let views = [lbTitle, lbDesc, lbBuyPrice, lbSellPrice]
        views.forEach { subView in
            subView.backgroundColor = UIColor.clear
            v.addSubview(subView)
        }
        let space : CGFloat = 8
        //
        lbTitle.autoPinEdge(toSuperviewEdge: .top)
        lbTitle.autoAlignAxis(toSuperviewAxis: .vertical)
        //
        lbDesc.autoPinEdge(.top, to: .bottom, of: lbTitle, withOffset: space/2)
        lbDesc.autoAlignAxis(toSuperviewAxis: .vertical)
        //
        lbBuyPrice.autoPinEdge(.top, to: .bottom, of: lbDesc, withOffset: space)
        lbBuyPrice.autoAlignAxis(toSuperviewAxis: .vertical)
        
        lbSellPrice.autoPinEdge(.top, to: .bottom, of: lbBuyPrice, withOffset: space/2)
        lbSellPrice.autoAlignAxis(toSuperviewAxis: .vertical)
        
        v.autoPinEdge(.bottom, to: .bottom, of: lbSellPrice)
        
        return v
    }()
    
    lazy var lbTitle : UILabel = {
        let v = UILabel()
        v.font = UIFont.titleFont()
        v.textColor = UIColor.titleColor()
        return v
    }()
    
    lazy var lbDesc: UILabel = {
        let v = UILabel()
        v.font = UIFont.descFont()
        v.textColor = UIColor.descColor()
        return v
    }()
    
    lazy var lbBuyPrice: UILabel = {
        let v = UILabel()
        v.font = UIFont.buyPriceFont()
        v.textColor = UIColor.buyPriceColor()
        return v
    }()
    
    lazy var lbSellPrice: UILabel = {
        let v = UILabel()
        v.font = UIFont.sellPriceFont()
        v.textColor = UIColor.sellPriceColor()
        return v
    }()
    
    var model : CoinModel? {
        didSet {
            guard let model = model else {
                return
            }
            lbTitle.text = model.name
            lbDesc.text = model.base
            lbBuyPrice.text = "\(model.buyPrice ?? "0.0") \(model.counter ?? "")"
            lbSellPrice.text = "\(model.sellPrice ?? "0.0") \(model.counter ?? "")"
            let defaultImage = UIImage.iconFont(IconFont.ic_coin_default, fontSize: FontSize.h0, color: UIColor.lightGray)
            imv.setImage(with: URL(string: model.icon ?? ""), defaultImage: defaultImage)
        }
    }
    
    override func makeUI() {
        view.backgroundColor = .white
        let views = [btnBack, imv, vInfo]
        views.forEach { v in
            view.addSubview(v)
        }
        
        let space : CGFloat = ScreenSize.LEADING

        btnBack.autoPinEdge(toSuperviewEdge: .top, withInset: ScreenSize.STATUS_BAR_HEIGHT)
        btnBack.autoPinEdge(toSuperviewEdge: .left, withInset: space/2)
        btnBack.autoSetDimensions(to: CGSize(width: 44, height: 44))
        
        imv.autoPinEdge(toSuperviewEdge: .top, withInset: ScreenSize.STATUS_BAR_HEIGHT)
        imv.autoAlignAxis(toSuperviewAxis: .vertical)
        imv.autoSetDimensions(to: CGSize(width: 40, height: 40))
        
        vInfo.autoPinEdge(.top, to: .bottom, of: imv, withOffset: space/2)
        vInfo.autoPinEdge(toSuperviewEdge: .left, withInset: space)
        vInfo.autoPinEdge(toSuperviewEdge: .right, withInset: space)
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        guard let vm = viewModel as? CoinDetailVM else {
            return
        }
        
        model = vm.coin
    }
}

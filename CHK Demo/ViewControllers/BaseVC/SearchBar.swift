//
//  SearchBar.swift
//  CHK Demo
//
//  Created by Dan Tran Thanh  on 16/08/2021.
//

import UIKit
import RxCocoa
import RxSwift
import RxGesture

class SearchBar : BaseView {
    public var cancelButtonClicked = PublishSubject<Void>()
    
    public var searchButtonClicked = PublishSubject<UITextField>()
    
    public var textDidBeginEditing = PublishSubject<UITextField>()
    
    public var textDidEndEditing = PublishSubject<UITextField>()
    public var textSignal = BehaviorRelay<String>(value: "")
    //
    public var text : String? {
        get {
            return self.tfSeach.text
        }
        
        set {
            self.tfSeach.text = newValue
        }
    }
    
    public var placeholder : String? {
        didSet {
            self.tfSeach.attributedPlaceholder = NSAttributedString(string: placeholder ?? "",
                                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        }
    }
    
    lazy var vContent : UIView = {
        let v = UIView.newAutoLayout()
        v.backgroundColor = .clear
        return v
    }()
    
    lazy var vSearch : UIView = {
        let v = UIView.newAutoLayout()
        v.backgroundColor = .clear
        v.makeCorner()
        v.makeBorder(color: UIColor.lightGray, width: 1)
        return v
    }()
    
    lazy var tfSeach : TintTextField = {
        let v = TintTextField.newAutoLayout()
        v.tintColor = UIColor.gray
        v.font = .titleFont()
        v.textColor = .titleColor()
        v.attributedPlaceholder = NSAttributedString(string: "Search",
                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        v.clearButtonMode = .whileEditing
        v.returnKeyType = .search
        v.delegate = self
        v.rx.text.orEmpty.bind(to: self.textSignal).disposed(by: disposeBag)
        return v
    }()
    
    lazy var btnCancel : UIButton = {
        let v = UIButton.newAutoLayout()
        v.setTitle("Cancel", for: .normal)
        v.titleLabel?.font = .titleFont()
        v.titleLabel?.textAlignment = .right
        v.setTitleColor(.gray, for: .normal)
        v.setTitleColor(.lightGray, for: .highlighted)
        v.setTitleColor(.lightGray, for: .disabled)
        v.rx.tap.bind { [weak self] in
            guard let self = self else { return }
            self.tfSeach.resignFirstResponder()
            self.cancelButtonClicked.onNext(())
        }.disposed(by: disposeBag)
        v.contentHorizontalAlignment = .right
        return v
    }()
    
    lazy var imvSearch : UIImageView = {
        let v = UIImageView.newAutoLayout()
        v.iconFont(IconFont.ic_search, fontSize: 20, color: UIColor.gray)
        v.contentMode = .scaleAspectFit
        v.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self]_ in
                self?.tfSeach.becomeFirstResponder()
            }).disposed(by: disposeBag)
        return v
    }()
    
    override func makeUI() {
        super.makeUI()
        //
        addSubview(vContent)
        vContent.addSubview(vSearch)
        vSearch.addSubview(imvSearch)
        vSearch.addSubview(tfSeach)
        vContent.addSubview(btnCancel)
        //
        let margin : CGFloat = 4
        //
        vContent.autoPinEdgesToSuperviewEdges()
        //
        vSearch.autoPinEdge(toSuperviewEdge: .left)
        vSearch.autoPinEdge(toSuperviewEdge: .top)
        vSearch.autoPinEdge(toSuperviewEdge: .bottom)
        vSearch.autoPinEdge(.right, to: .left, of: btnCancel)
        ///
        imvSearch.autoPinEdge(toSuperviewEdge: .left, withInset: 2*margin)
        imvSearch.autoAlignAxis(toSuperviewAxis: .horizontal)
        imvSearch.autoSetDimensions(to: CGSize(width: 16, height: 16))
        ///
        tfSeach.autoPinEdge(toSuperviewEdge: .top)
        tfSeach.autoPinEdge(toSuperviewEdge: .right, withInset: margin)
        tfSeach.autoPinEdge(toSuperviewEdge: .bottom)
        tfSeach.autoPinEdge(.left, to: .right, of: imvSearch, withOffset: margin)
        //
        btnCancel.autoPinEdge(toSuperviewEdge: .right)
        btnCancelWidthConstraint = btnCancel.autoSetDimension(.width, toSize: 0)
        btnCancel.autoAlignAxis(toSuperviewAxis: .horizontal)
    }
    
    private var btnCancelWidthConstraint : NSLayoutConstraint?
    private var isShowCancelButton = false
    
    func showCancelButton(_ isShow: Bool, animated: Bool) {
        if isShowCancelButton == isShow {
            return
        }
        isShowCancelButton = isShow
        let padding : CGFloat = 16
        let text = btnCancel.titleLabel?.text
        let w = text?.width(font: .titleFont(), height: 24, maxWidth: 200) ?? 0
        btnCancelWidthConstraint?.constant = isShow ? w + padding : 0
        UIView.animate(withDuration: animated ? 0.25 : 0) { [weak self] in
            guard let self = self else { return }
            self.btnCancel.alpha = isShow ? 1 : 0
            self.layoutIfNeeded()
        }
    }
}

extension SearchBar : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.textDidBeginEditing.onNext(textField)
        self.showCancelButton(true, animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.textDidEndEditing.onNext(textField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.searchButtonClicked.onNext(textField)
        return true
    }
}


class TintTextField: UITextField {
    
    var tintedClearImage: UIImage?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.tintClearImage()
    }
    
    private func tintClearImage() {
        for view in subviews {
            if view is UIButton {
                let button = view as! UIButton
                if let image = button.image(for: .highlighted) {
                    if self.tintedClearImage == nil {
                        tintedClearImage = self.tintImage(image: image, color: self.tintColor)
                    }
                    button.setImage(self.tintedClearImage, for: .normal)
                    button.setImage(self.tintedClearImage, for: .highlighted)
                }
            }
        }
    }
    
    private func tintImage(image: UIImage, color: UIColor) -> UIImage {
        let size = image.size
        
        UIGraphicsBeginImageContextWithOptions(size, false, image.scale)
        let context = UIGraphicsGetCurrentContext()
        image.draw(at: .zero, blendMode: CGBlendMode.normal, alpha: 1.0)
        
        context?.setFillColor(color.cgColor)
        context?.setBlendMode(CGBlendMode.sourceIn)
        context?.setAlpha(1.0)
        
        let rect = CGRect(x: CGPoint.zero.x, y: CGPoint.zero.y, width: image.size.width, height: image.size.height)
        UIGraphicsGetCurrentContext()?.fill(rect)
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return tintedImage ?? UIImage()
    }
}

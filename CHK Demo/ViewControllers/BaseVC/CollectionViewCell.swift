//
//  CollectionViewCell.swift
//  CHK Demo
//
//  Created by Dan Tran Thanh  on 17/08/2021.
//

import UIKit
import RxSwift
import RxCocoa

class CollectionViewCell: UICollectionViewCell {
    
    static var cellId : String {
        return "\(Self.self)"
    }
    
    var disposeBag = DisposeBag()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        // setup UI
        makeUI()
        bindModel()
        // update constraints
        setNeedsUpdateConstraints()
    }
    
    private var didUpdateConstraints = false
    private var didLayoutSubviews = false
    
    override func updateConstraints() {
        if !didUpdateConstraints {
            makeConstraints()
            didUpdateConstraints = true
        }
        super.updateConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !didLayoutSubviews {
            didLayout()
            didLayoutSubviews = true
        }
    }
    
    // MARK: - Public functions
    
    func makeUI() {}
    func bindModel() {}
    func makeConstraints() {}
    func didLayout() {}
    
    // MARK: - Deinit
    
    deinit {
        disposeBag = DisposeBag()
        Logger.log(message: "\(Self.self) - Deinit")
    }
}

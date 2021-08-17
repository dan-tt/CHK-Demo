//
//  BaseView.swift
//  CHK Demo
//
//  Created by Dan Tran Thanh  on 16/08/2021.
//

import UIKit
import RxSwift
class BaseView: UIView {
    private var didUpdateConstraints = false
    private var didLayoutSubviews = false
    var disposeBag = DisposeBag()
    
    weak var vc : UIViewController?
    init() {
        super.init(frame: .zero)
        //
        translatesAutoresizingMaskIntoConstraints = false;
        backgroundColor = .clear
        // setup UI
        makeUI()
        // bind model
        bindModel()
        // update constraints
        setNeedsUpdateConstraints()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false;
        backgroundColor = .clear
        makeUI()
        bindModel()
        setNeedsUpdateConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        disposeBag = DisposeBag()
        Logger.log(message: "\(Self.self) - Deinit")
    }
    
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
    
    func viewWillAppear(_ animated: Bool) {}
    func viewDidAppear(_ animated: Bool) {}
    func viewDidDisappear(_ animated: Bool) {}
}

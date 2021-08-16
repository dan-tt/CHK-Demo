//
//  TableViewCell.swift
//  CHK Demo
//
//  Created by Dan Tran Thanh  on 16/08/2021.
//

import UIKit
import RxSwift

class TableViewCell: UITableViewCell {
    static var cellId : String {
        return "\(Self.self)"
    }
    
    var disposeBag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .clear
        makeUI()
        bindModel()
        setNeedsUpdateConstraints()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        makeUI()
        bindModel()
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
        contentView.layoutSubviews()
        if !didLayoutSubviews {
            didLayout()
            didLayoutSubviews = true
        }
    }
    
    // MARK: - Public functions
    
    func makeUI() {
        self.selectionStyle = .none
    }
    func bindModel() {}
    func makeConstraints() {}
    func didLayout() {}
    
    // MARK: - Deinit
    
    deinit {
        disposeBag = DisposeBag()
        Logger.log(message: "\(Self.self) - Deinit")
    }
}

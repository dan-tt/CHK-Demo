//
//  BaseVM.swift
//  CHK Demo
//
//  Created by Dan Tran Thanh  on 16/08/2021.
//

import UIKit
import RxSwift
import RxCocoa

protocol BaseVMType{
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}

@objc protocol BaseVMDataSource {
    @objc func sizeForItemAt(indexPath: IndexPath) -> CGSize
    @objc func didSelect(item: Any?)
}

class BaseVM: NSObject {
    
    var api: API?

    var disposeBag = DisposeBag()
    
    let refreshSignal = PublishSubject<Void>()
    let loadingSignal = BehaviorRelay(value: true)
    let canLoadMoreSignal = BehaviorRelay(value: false)

    let errorSignal = PublishSubject<ResponseError>()
    let dismissSignal = PublishSubject<Void>()
    
    let headerLoading = ActivityIndicator()
    let footerLoading = ActivityIndicator()
    
    var page = 1
    
    //
    init(api: API?) {
        super.init()
        self.api = api
    }
    
    deinit {
        disposeBag = DisposeBag()
        Logger.log(message: "\(Self.self) deinit")
    }
}

extension BaseVM: BaseVMDataSource {
    
    func sizeForItemAt(indexPath: IndexPath) -> CGSize {
        return .zero
    }
    
    func didSelect(item: Any?) {
        if let coin = item as? CoinModel {
            let vm = CoinDetailVM(coin: coin, api: api)
            Navigator.default.show(segue: .coinDetail(viewModel: vm), sender: nil)
            return
        }
    }
}

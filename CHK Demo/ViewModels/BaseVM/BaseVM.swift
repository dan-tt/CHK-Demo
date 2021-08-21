//
//  BaseVM.swift
//  CHK Demo
//
//  Created by Dan Tran Thanh  on 16/08/2021.
//

import UIKit
import RxSwift
import RxCocoa
import ObjectMapper

protocol BaseVMType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}

protocol BaseDataSource : AnyObject {
    func sizeForItemAt(indexPath: IndexPath) -> CGSize
}

class BaseVM: NSObject {
    
    weak var api: API?
    weak var baseDataSource : BaseDataSource?

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
    
    func didSelect(item: Any?) {
        if let coin = item as? CoinModel {
            let vm = CoinDetailVM(coin: coin, api: api)
            Navigator.default.show(segue: .coinDetail(viewModel: vm), sender: nil)
            return
        }
    }

    
    deinit {
        disposeBag = DisposeBag()
        Logger.log(message: "\(Self.self) deinit")
    }
}

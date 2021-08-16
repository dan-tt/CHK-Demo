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

class BaseVM: NSObject {
    var disposeBag = DisposeBag()
    
    let refreshSignal = PublishSubject<Void>()
    let loadingSignal = BehaviorRelay(value: true)
    let canLoadMoreSignal = BehaviorRelay(value: false)

    let errorSignal = PublishSubject<ResponseError>()
    let dismissSignal = PublishSubject<Void>()
    
    let headerLoading = ActivityIndicator()
    let footerLoading = ActivityIndicator()
    
    var page = 1
    
    deinit {
        disposeBag = DisposeBag()
        Logger.log(message: "\(Self.self) deinit")
    }
}

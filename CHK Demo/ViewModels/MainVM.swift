//
//  MainVM.swift
//  CHK Demo
//
//  Created by Dan Tran Thanh  on 16/08/2021.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

struct CoinSection {
    var items: [CoinModel]
    var headerTitle : String?
}

extension CoinSection: AnimatableSectionModelType {
    
    var identity: Identity {
        return headerTitle ?? "0"
    }
    
    typealias Identity = String
    
    init(original: CoinSection, items: [CoinModel]) {
        self = original
        self.items = items
    }
}

class MainVM: BaseVM, BaseVMType {
    struct Input {
        let headerTrigger: Observable<Void>
        let footerTrigger: Observable<Void>
        let selectionTrigger: Driver<CoinModel>
    }
    
    struct Output {
        let items: Driver<[CoinModel]>
        let searchResult: Driver<[CoinModel]>
    }
    
    let elements = BehaviorRelay<[CoinModel]>(value: [])
    let searchElements = BehaviorRelay<[CoinModel]>(value: [])

    func transform(input: Input) -> Output {
        // refresh
        input.headerTrigger.flatMapLatest({ [unowned self] () -> Observable<[CoinModel]> in
            self.canLoadMoreSignal.accept(false)
            self.page = 1
            return self.request().trackActivity(self.headerLoading)
        }).subscribe(onNext: { [unowned self](items) in
            self.elements.accept(items)
        }).disposed(by: disposeBag)
        // load more
        input.footerTrigger.flatMapLatest({ [unowned self] () -> Observable<[CoinModel]> in
            self.page += 1
            return self.request().trackActivity(self.footerLoading)
        }).subscribe(onNext: { [unowned self](items) in
            var curItems = self.elements.value
            items.forEach { (item) in
                guard let _ = curItems.first(where: {$0.base == item.base}) else {
                    curItems.append(item)
                    return
                }
            }
            self.elements.accept(curItems)
            
        }).disposed(by: disposeBag)
        
        // did select item
        input.selectionTrigger.drive(onNext:{(item) in
        }).disposed(by: disposeBag)
        
        return Output(items: elements.asDriver(), searchResult: searchElements.asDriver())
    }
    
    func request() -> Observable<[CoinModel]> {
        return Observable.create({ [unowned self]observer in
            self.loadingSignal.accept(true)
            APIService.shared.getListCoin(counter: "USD").subscribe { results, isMore in
                self.loadingSignal.accept(false)
                self.canLoadMoreSignal.accept(isMore ?? false)
                observer.onNext(results ?? [])
                observer.onCompleted()
                
            } onError: { error in
                let e = ResponseError.init(224, error.localizedDescription)
                self.errorSignal.onNext(e)
            }.disposed(by: self.disposeBag)
            return Disposables.create()
        })
    }
    
    func search(with text: String?) {
        let items = elements.value
        guard items.count > 0 else {
            return
        }
        guard let text = text?.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines),
              !text.isEmpty else {
            searchElements.accept(items)
            return
        }
        let result = items.filter({($0.name?.lowercased().contains(text) ?? false) || ($0.base?.lowercased().contains(text) ?? false)})
        searchElements.accept(result)
    }
}

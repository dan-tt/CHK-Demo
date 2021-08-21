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
        let selectionTrigger: Driver<CoinModel>
        let searchTrigger: Driver<String?>
    }
    
    struct Output {
        let items: Driver<[CoinModel]>
        let searchResult: Driver<[CoinModel]>
    }
        
    let elements = BehaviorRelay<[CoinModel]>(value: [])
    //
    private var observers : [Any] = []

    // refresh timer
    let timeCount : Double = 30 // 30s
    //
    func transform(input: Input) -> Output {
        baseDataSource = self
        addObservers()
        // refresh
        let items = input.headerTrigger.flatMapLatest({ [unowned self] () -> Observable<[CoinModel]> in
            self.canLoadMoreSignal.accept(false)
            self.page = 1
            return self.request().trackActivity(self.headerLoading)
        })
        .asDriver { error -> Driver<[CoinModel]> in
            Logger.log(message: "get list coins error \(error.localizedDescription)")
            return Driver.just([])
        }

        // search
        let searchResult = input.searchTrigger.asObservable().flatMapLatest { text in
            self.requestSearch(text: text)
        }.asDriver { error -> Driver<[CoinModel]> in
            Logger.log(message: "search error \(error.localizedDescription)")
            return Driver.just([])
        }
        
        // did select item
        input.selectionTrigger.drive(onNext:{[unowned self](item) in
            self.didSelect(item: item)
        }).disposed(by: disposeBag)
        //
        items.asObservable().bind(to: elements).disposed(by: disposeBag)
        
        return Output(items: items, searchResult: searchResult)
    }
    
    func request() -> Observable<[CoinModel]> {
        guard let api = api else {
            return Observable.error(ResponseError())
        }
        self.loadingSignal.accept(true)
        return Observable.create({ [unowned self]observer in
            var request: Single<[CoinModel]>
            request = api.getListCoint(counter: "USD")
            request.asObservable().subscribe { items in
                self.loadingSignal.accept(false)
                observer.onNext(items)
                observer.onCompleted()
                
            } onError: { error in
                observer.onError(error)
                
            } onCompleted: {
                // fetch data after 30s
                DispatchQueue.main.asyncAfter(deadline: .now() + self.timeCount) {
                    self.refreshSignal.onNext(())
                }
            }.disposed(by: disposeBag)
            
            return Disposables.create()
        })
    }
    
    func requestSearch(text: String?) -> Observable<[CoinModel]> {
        return Observable.create({ [unowned self]observer in
            let items = elements.value
            guard let text = text?.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines),
                  !text.isEmpty else {
                observer.onNext(items)
                observer.onCompleted()
                return Disposables.create()
            }
            let result = items.filter({($0.name?.lowercased().contains(text) ?? false) || ($0.base?.lowercased().contains(text) ?? false)})
            observer.onNext(result)
            observer.onCompleted()
            return Disposables.create()
        })
    }
}

// MARK: - BaseVMDataSource

extension MainVM : BaseDataSource {
    func sizeForItemAt(indexPath: IndexPath) -> CGSize {
        let h : CGFloat = 80
        if UIDevice.current.userInterfaceIdiom == .pad {
            let w = (ScreenSize.SCREEN_MIN_LENGTH - ScreenSize.LEADING)/2.0
            return CGSize(width: w, height: h)
        }
        
        let w = ScreenSize.SCREEN_MIN_LENGTH
        return CGSize(width: w, height: h)
    }
}


// MARK: - private funcs

extension MainVM {
    // add observers
    private func addObservers() {
        NotificationCenter.default.rx.notification(UIApplication.willEnterForegroundNotification)
            .subscribe { [unowned self]_ in
                self.refreshSignal.onNext(())
            }.disposed(by: disposeBag)
    }
}

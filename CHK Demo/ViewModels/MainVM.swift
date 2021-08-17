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
import UIDeviceComplete

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
    //
    private var observers : [Any] = []

    // refresh timer
    let timeCount : Int = 30 // 30s
    private var refreshTime : Int = 0
    private var refreshTimer : Timer?
    //
    func transform(input: Input) -> Output {
        addObservers()
        // refresh
        input.headerTrigger.flatMapLatest({ [unowned self] () -> Observable<[CoinModel]> in
            self.canLoadMoreSignal.accept(false)
            self.page = 1
            self.stopCount()
            return self.request().trackActivity(self.headerLoading)
        }).subscribe(onNext: { [unowned self](items) in
            self.elements.accept(items)
            self.startCount()
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
                observer.onError(error)
                
            }.disposed(by: self.disposeBag)
            
            return Disposables.create()
        })
    }
    
    override func sizeForItemAt(indexPath: IndexPath) -> CGSize {
        let h : CGFloat = 80
        if UIDevice.current.dc.isIpad {
            let w = (ScreenSize.SCREEN_MIN_LENGTH - ScreenSize.LEADING)/2.0
            return CGSize(width: w, height: h)
        }
        
        let w = ScreenSize.SCREEN_MIN_LENGTH
        return CGSize(width: w, height: h)
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
        
    deinit {
        removeObservers()
    }
}

// MARK: - private funcs

extension MainVM {
    // start timer refresh data
    private func startCount() {
        guard self.refreshTimer == nil else {
            return
        }
        self.refreshTime = 0
        self.refreshTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [unowned self]timer in
            self.refreshTime += 1
            if self.refreshTime > self.timeCount {
                self.refreshTime = 0
                self.refreshSignal.onNext(())
            }
        }
        // register to NSrunloop
        if let timer = self.refreshTimer {
            RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
        }
    }
    // start timer refresh data
    private func stopCount() {
        refreshTimer?.invalidate()
        refreshTimer = nil
        refreshTime = 0
    }
    // add observers
    private func addObservers() {
        if !observers.isEmpty {
            return
        }
        // stop timer when the app did enter background
        observers.append(NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil, using: { [unowned self] (notification) in
            self.stopCount()
        }))
        
        // start timer when the app will enter foreground
        observers.append(NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: nil, using: { [unowned self] (notification) in
             self.startCount()
        }))
    }
    
    private func removeObservers() {
        observers.forEach { (obs) in
            NotificationCenter.default.removeObserver(obs)
        }
        observers.removeAll()
    }
    
}

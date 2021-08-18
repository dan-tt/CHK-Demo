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
        let selectionTrigger: Driver<CoinModel>
        let searchTrigger: Driver<String?>
    }
    
    struct Output {
        let items: Driver<[CoinModel]>
        let searchResult: Driver<[CoinModel]>
    }
    
    weak var apiService : APIService?
    
    let elements = BehaviorRelay<[CoinModel]>(value: [])
    //
    private var observers : [Any] = []

    // refresh timer
    let timeCount : Int = 30 // 30s
    private var refreshTime : Int = 0
    private var refreshTimer : Timer?
    //
    init(apiService: APIService = APIService.shared) {
        super.init()
        self.apiService = apiService
    }
    //
    func transform(input: Input) -> Output {
        addObservers()
        // refresh
        let items = input.headerTrigger.flatMapLatest({ [unowned self] () -> Observable<[CoinModel]> in
            self.canLoadMoreSignal.accept(false)
            self.page = 1
            self.stopCount()
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
        return Observable.create({ [unowned self]observer in
            self.loadingSignal.accept(true)
            
            self.apiService?.getListCoin(counter: "USD").subscribe { results, isMore in
                self.loadingSignal.accept(false)
                self.canLoadMoreSignal.accept(isMore ?? false)
                observer.onNext(results ?? [])
                observer.onCompleted()
                self.startCount()
                
            } onError: { error in
                let e = ResponseError.init(224, error.localizedDescription)
                self.errorSignal.onNext(e)
                observer.onError(error)
                self.startCount()
                
            }.disposed(by: self.disposeBag)
            
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
    
    override func sizeForItemAt(indexPath: IndexPath) -> CGSize {
        let h : CGFloat = 80
        if UIDevice.current.dc.isIpad {
            let w = (ScreenSize.SCREEN_MIN_LENGTH - ScreenSize.LEADING)/2.0
            return CGSize(width: w, height: h)
        }
        
        let w = ScreenSize.SCREEN_MIN_LENGTH
        return CGSize(width: w, height: h)
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

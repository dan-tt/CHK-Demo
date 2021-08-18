//
//  CHK_DemoTests.swift
//  CHK DemoTests
//
//  Created by Dan Tran Thanh  on 16/08/2021.
//

import XCTest
import RxCocoa
import RxSwift
import RxTest
import RxBlocking

@testable import CHK_Demo

class CHK_DemoTests: XCTestCase {
    
    var viewModel : MainVM!
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    fileprivate var apiService: MockAPIService!

    override func setUp() {
        super.setUp()
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        apiService = MockAPIService()
        viewModel = MainVM(apiService: apiService)
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testGetListCoinEmpty() {
        // create sheduler
        let items = scheduler.createObserver([CoinModel].self)
        // giving a service with no coin
        apiService.coins = nil
        //
        let refreshTrigger = PublishSubject<Void>()
        let selectionTrigger =  BehaviorRelay<CoinModel>(value: CoinModel())
        let searchTrigger =  BehaviorRelay<String?>(value: nil)

        let input = MainVM.Input(headerTrigger: refreshTrigger,
                                 selectionTrigger: selectionTrigger.asDriver(),
                                 searchTrigger: searchTrigger.asDriver())
        
        let output = viewModel.transform(input: input)
        // bind the result
        output.items.drive(items).disposed(by: disposeBag)
        //
        scheduler.createColdObservable([.next(10, ())])
            .bind(to: refreshTrigger)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(items.events, [.next(10, []), .completed(10)])
    }
    
    func testGetListCoin() {
        // create sheduler
        let items = scheduler.createObserver([CoinModel].self)
        // giving a service mocking coins
        var coin = CoinModel()
        coin.base = "LTC"
        coin.counter = "USD"
        coin.buyPrice = "169.603"
        coin.sellPrice = "168.894"
        coin.icon = "https://cdn.coinhako.com/assets/wallet-ltc-e4ce25a8fb34c45d40165b6f4eecfbca2729c40c20611acd45ea0dc3ab50f8a6.png"
        coin.name = "Litecoin"
        apiService.coins = [coin]
        //
        let refreshTrigger = PublishSubject<Void>()
        let selectionTrigger =  BehaviorRelay<CoinModel>(value: coin)
        let searchTrigger =  BehaviorRelay<String?>(value: nil)

        let input = MainVM.Input(headerTrigger: refreshTrigger,
                                 selectionTrigger: selectionTrigger.asDriver(),
                                 searchTrigger: searchTrigger.asDriver())
        
        let output = viewModel.transform(input: input)
        // bind the result
        output.items.drive(items).disposed(by: disposeBag)
        // mock a refresh
        scheduler.createColdObservable([.next(10, ()), .next(30, ())])
            .bind(to: refreshTrigger)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(items.events, [.next(10, [coin]), .next(30, [coin])])
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

fileprivate class MockAPIService : APIService {

    var coins : [CoinModel]?
    
    override func getListCoin(counter: String) -> Observable<(res: [CoinModel]?, isLoadMore: Bool?)> {
        return Observable.create { [unowned self]observer in
            if let res = coins {
                observer.onNext((res, false))
                observer.onCompleted()
            } else {
                observer.onError(ResponseError.init(224, "No data"))
            }
            return Disposables.create()
        }
    }
}

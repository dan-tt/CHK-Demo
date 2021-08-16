//
//  API.swift
//  CHK Demo
//
//  Created by Dan Tran Thanh  on 16/08/2021.
//

import Foundation
import RxSwift
import RxCocoa
import ObjectMapper

extension APIService {
    
    // MARK: - APIs Home
    
    func getListCoin(counter: String) -> Observable<(res: [CoinModel]?, isLoadMore: Bool?)> {
        return Observable.create { [unowned self]observer in
            self.request(apiRouter: APIRouter.getListCoin(counter: counter)).subscribe { response in
                let model = Mapper<CoinModel>().mapArray(JSONObject: response?.data)
                observer.onNext((model, false))
                observer.onCompleted()
            } onError: { error in
                observer.onError(error)
            }.disposed(by: disposeBag)
            return Disposables.create()
        }
    }
}

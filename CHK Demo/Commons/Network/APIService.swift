//
//  APIService.swift
//  CHK Demo
//
//  Created by Dan Tran Thanh  on 16/08/2021.
//

import Foundation
import RxSwift
import Alamofire
import ObjectMapper
import AlamofireObjectMapper

class APIService: NSObject {
    static let shared = APIService()
    
    // MARK: - Init
    override init() {
        super.init()
    }
    
    func isConnectToInternet() -> Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
    
    // MARK: - Request
    
    func request(apiRouter: APIRouter) -> Observable<ResponseModel?> {
        return Observable.create { observer in
            let urlString = apiRouter.urlRequest?.url?.absoluteString
            let request = AF.request(apiRouter).responseObject { (response: AFDataResponse<ResponseModel>) in
                switch response.result {
                case .success:
                    let responseObj = response.value
                    Logger.log(message: "Response: ", object: "<URL:\(urlString ?? "")> \(responseObj?.toJSONString(prettyPrint: true) ?? "")")
                    observer.onNext(responseObj)
                    observer.onCompleted()
                    
                case .failure(let error):
                    let errorBase = ResponseError()
                    Logger.log(message: "Request Failed: ", object: "<URL:\(urlString ?? "")> \(error.localizedDescription)")
                    observer.onError(errorBase)
                }
            }
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
    // MARK:- APIs
    func getListCoin(counter: String) -> Observable<(res: [CoinModel]?, isLoadMore: Bool?)> {
        return Observable.create { [unowned self]observer in
            self.request(apiRouter: APIRouter.getListCoin(counter: counter)).subscribe { response in
                let model = Mapper<CoinModel>().mapArray(JSONObject: response?.data)
                observer.onNext((model, false))
                observer.onCompleted()
            } onError: { error in
                observer.onError(error)
            }.disposed(by: rx.disposeBag)
            return Disposables.create()
        }
    }
}

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

class APIService: API {

    init() {}
    
    // MARK: - Request
    
    func request(_ apiRouter: APIRouter) -> Observable<ResponseModel?> {
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
}

// MARK:- APIs
extension APIService {
    func getListCoint(counter: String) -> Single<[CoinModel]> {
        return requestArray(.getListCoin(counter: counter), type: CoinModel.self)
    }
}

extension APIService {
    private func requestObject<T: BaseMappable>(_ target: APIRouter, type: T.Type) -> Single<T?> {
        return request(target)
            .map({Mapper<T>().map(JSONObject: $0?.data)})
            .observe(on: MainScheduler.instance)
            .asSingle()
    }

    private func requestArray<T: BaseMappable>(_ target: APIRouter, type: T.Type) -> Single<[T]> {
        return request(target)
            .map({Mapper<T>().mapArray(JSONObject: $0?.data) ?? []})
            .observe(on: MainScheduler.instance)
            .asSingle()
    }
}

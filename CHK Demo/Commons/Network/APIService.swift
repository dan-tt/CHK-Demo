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
    var activePushInfo: Bool = false
    var isGettingAccessToken = false
    var isShowingPopupWarning: Bool = false
    var curTimeServer: TimeInterval = 0.0
    let timeEffectRefresh: TimeInterval = 3.0
    
    // MARK: - Init
    
    private override init() {
        super.init()
    }
    
    func isConnectToInternet() -> Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
    
    // MARK: - Others
    
    func updateTimeServer(time: TimeInterval) {
        if curTimeServer < time {
            curTimeServer = time
        }
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
}

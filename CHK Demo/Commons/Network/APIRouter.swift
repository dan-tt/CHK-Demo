//
//  APIRouter.swift
//  CHK Demo
//
//  Created by Dan Tran Thanh  on 16/08/2021.
//

import Foundation
import Alamofire

enum APIRouter {
    // MARK: - Defines
    case getListCoin(counter: String)
}

extension APIRouter: URLRequestConvertible {
    // MARK: - Path
    private var path: String {
        switch self {
        case .getListCoin:
            return "/price/all_prices_for_mobile"
        }
    }
    
    // MARK: - PMethod
    var method: HTTPMethod {
        switch self {
        case .getListCoin:
            return .get
        }
    }
    
    // MARK: - Parameters
    var parameters: Parameters? {
        var params: [String: Any] = [:]
        switch self {
        case .getListCoin(let counter):
            params["counter_currency"] = counter
        }
        return params
    }
    
    // MARK: - URL Request
    func asURLRequest() throws -> URLRequest {
        let url = try Production.BASE_URL.asURL().appendingPathComponent(path)
        
        var urlRequest: URLRequest = URLRequest(url: url)
        
        urlRequest.timeoutInterval = 30
        urlRequest.httpShouldHandleCookies = false
        urlRequest.httpMethod = method.rawValue

        if let parameters = parameters {
            do {
                let urlEncoding =  URLEncoding.init(destination: .methodDependent, arrayEncoding: .brackets, boolEncoding: .literal)
                urlRequest = try urlEncoding.encode(urlRequest, with: parameters)
            } catch {
                Logger.log(message: "Encoding fail")
            }
        }
        return urlRequest
    }
}


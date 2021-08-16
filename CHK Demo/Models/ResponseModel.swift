//
//  BaseResponseModel.swift
//  CHK Demo
//
//  Created by Dan Tran Thanh  on 16/08/2021.
//

import Foundation
import ObjectMapper

struct ResponseModel: Mappable {
    var data: Any?
    
    init?(map: Map) {}
        
    mutating func mapping(map: Map) {
        data <- map["data"]
    }
}

struct ResponseError: Error {
    var errorCode: Int?
    var errorMessage: String?
    
    init(_ code: Int = 0, _ message: String = "No data") {
        errorCode = code
        errorMessage = message
    }
}

//
//  Logger.swift
//  CHK Demo
//
//  Created by Dan Tran Thanh  on 16/08/2021.
//

import Foundation
class Logger {
    static func log(message: String, object: Any, file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        let className = (file as NSString).lastPathComponent
        print("<\(className), FUNCTION: \(function), LINE: \(line)> \(message)\(object)")
        #endif
    }
    
    static func logAPIError(_ error: ResponseError) {
        #if DEBUG
        print("API Error \(String(describing: error.errorCode)): \(String(describing: error.errorMessage))")
        #endif
    }
    
    static func log(message: String) {
        #if DEBUG
        print(message)
        #endif
    }
}

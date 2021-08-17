//
//  BaseObj.swift
//  CHK Demo
//
//  Created by Dan Tran Thanh  on 16/08/2021.
//

import Foundation
import ObjectMapper
import RxDataSources

struct CoinModel: Mappable, IdentifiableType, Equatable {
    static func == (lhs: CoinModel, rhs: CoinModel) -> Bool {
        return lhs.base == rhs.base &&
        lhs.buyPrice == rhs.buyPrice &&
        lhs.sellPrice == rhs.sellPrice
    }
    
    typealias Identity = String
    
    var identity: String{
        return base ?? "0"
    }
    var isLoading : Bool?
    var base: String?
    var name: String?
    var icon: String?
    var counter: String?
    var buyPrice: String?
    var sellPrice: String?
    
    init() {}
    
    init?(map: Map) {}
        
    mutating func mapping(map: Map) {
        base <- map["base"]
        name <- map["name"]
        icon <- map["icon"]
        counter <- map["counter"]
        buyPrice <- map["buy_price"]
        sellPrice <- map["sell_price"]
    }
}

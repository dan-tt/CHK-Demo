//
//  CoinDetailVM.swift
//  CHK Demo
//
//  Created by Dan Tran Thanh  on 18/08/2021.
//

import Foundation
class CoinDetailVM: BaseVM {
    var coin : CoinModel?
    init(coin: CoinModel, api: API?) {
        super.init(api: api)
        self.coin = coin
    }
}

//
//  CoinDetailVM.swift
//  CHK Demo
//
//  Created by Dan Tran Thanh  on 18/08/2021.
//

import Foundation
class CoinDetailVM: BaseVM {
    var coin : CoinModel?
    init(coin: CoinModel) {
        super.init()
        self.coin = coin
    }
}

//
//  API.swift
//  CHK Demo
//
//  Created by Dan Tran Thanh  on 20/08/2021.
//

import Foundation
import RxCocoa
import RxSwift

protocol API {
    func getListCoint(counter: String) -> Single<[CoinModel]>
}

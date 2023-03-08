//
//  CoinData.swift
//  CoinFlip Project
//
//  Created by Travis Young on 2/22/23.
//

import Foundation

struct CoinData : Decodable {
    let name: String
    let image : String
    let current_price : Double
    let symbol : String
    let price_change_percentage_1h_in_currency : Double
    let price_change_percentage_24h_in_currency : Double
    let price_change_percentage_7d_in_currency : Double
    let sparkline_in_7d : SparklineIn7d
}

struct SparklineIn7d: Decodable {
    let price: [Double]
}

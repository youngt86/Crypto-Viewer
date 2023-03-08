//
//  CoinManager.swift
//  CoinFlip Project
//
//  Created by Travis Young on 2/22/23.
//

import Foundation
import UIKit

protocol CoinManagerDelegate {
    func didFailWithError(error: Error)
    func didUpdateCoinData(_ coinManager: CoinManager, coins: [CoinModel])
}

struct CoinManager {
    
    let baseURL = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&sparkline=true&price_change_percentage=1h%2C24h%2C7d&per_page=3"
    
    var delegate: CoinManagerDelegate?
    
    func getCoinData(page: Int) {
        let urlString = "\(baseURL)&page=\(page)"
        performRequest(with: urlString)
    }
    
    func getCoinData(searchedCoin : String) {
        let urlString = "\(baseURL)&ids=\(searchedCoin.lowercased())"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString : String) {
        //1. Create a URL
        if let url = URL(string: urlString) {
            //2. Create a URLSession
            let session = URLSession(configuration: .default)
            
            //3. Give the session a task
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    let coins = self.parseJSON(safeData)
                    delegate?.didUpdateCoinData(self, coins: coins)
                }
            }
            //4. Start the task
            task.resume()
        }
    }
    
    func parseJSON(_ coinData: Data) -> [CoinModel] {
        let decoder = JSONDecoder()
        var coins: [CoinModel] = []
        do {
            let decodedData = try decoder.decode([CoinData].self, from: coinData)
            for coinData in decodedData {
                let name = coinData.name
                let image = coinData.image
                let currentPrice = coinData.current_price
                let symbol = coinData.symbol
                let percentage1hour = coinData.price_change_percentage_1h_in_currency
                let percentage24hours = coinData.price_change_percentage_24h_in_currency
                let percentage7days = coinData.price_change_percentage_7d_in_currency
                let prices = coinData.sparkline_in_7d.price
                let coin = CoinModel(name: name, coinImage: image, currency: currentPrice, symbol: symbol, percentage1hour: percentage1hour, percentage24hours: percentage24hours, percentage7days: percentage7days, prices: prices)
                coins.append(coin)
            }
            return coins
        } catch {
            delegate?.didFailWithError(error: error)
            return []
        }
    }
}



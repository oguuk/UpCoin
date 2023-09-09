//
//  TickerResponse.swift
//  UpStock
//
//  Created by 오국원 on 2023/07/28.
//

import Foundation

// MARK: - WelcomeElement

typealias TickerResponses = [TickerResponse]

struct TickerResponse: Codable {
        
    let market, tradeDate, tradeTime, tradeDateKst: String
    let tradeTimeKst: String
    let tradeTimestamp: Int
    let openingPrice, highPrice, lowPrice: Double
    let tradePrice, prevClosingPrice: Double
    let change: String
    let changePrice, changeRate: Double
    let signedChangePrice, signedChangeRate, tradeVolume, accTradePrice, accTradePrice24H: Double
    let accTradeVolume, accTradeVolume24H: Double
    let highest52_WeekPrice: Double
    let highest52_WeekDate: String
    let lowest52_WeekPrice: Double
    let lowest52_WeekDate: String
    let timestamp: Int
    var bookmark: Bool = false

    enum CodingKeys: String, CodingKey {
        case market
        case tradeDate = "trade_date"
        case tradeTime = "trade_time"
        case tradeDateKst = "trade_date_kst"
        case tradeTimeKst = "trade_time_kst"
        case tradeTimestamp = "trade_timestamp"
        case openingPrice = "opening_price"
        case highPrice = "high_price"
        case lowPrice = "low_price"
        case tradePrice = "trade_price"
        case prevClosingPrice = "prev_closing_price"
        case change
        case changePrice = "change_price"
        case changeRate = "change_rate"
        case signedChangePrice = "signed_change_price"
        case signedChangeRate = "signed_change_rate"
        case tradeVolume = "trade_volume"
        case accTradePrice = "acc_trade_price"
        case accTradePrice24H = "acc_trade_price_24h"
        case accTradeVolume = "acc_trade_volume"
        case accTradeVolume24H = "acc_trade_volume_24h"
        case highest52_WeekPrice = "highest_52_week_price"
        case highest52_WeekDate = "highest_52_week_date"
        case lowest52_WeekPrice = "lowest_52_week_price"
        case lowest52_WeekDate = "lowest_52_week_date"
        case timestamp
    }
}

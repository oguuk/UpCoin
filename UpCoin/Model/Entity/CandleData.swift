//
//  CandleData.swift
//  UpStock
//
//  Created by 오국원 on 2023/08/02.
//

import Foundation

typealias CandleDatas = [CandleData]

struct CandleData: Codable {
    let market, candleDateTimeUTC, candleDateTimeKst: String
    let openingPrice, highPrice, lowPrice, tradePrice: Double
    let timestamp, candleAccTradePrice, candleAccTradeVolume: Double
    let prevClosingPrice: Double?
    let changePrice: Double?
    let changeRate: Double?
    let unit: Int?
    let firstDayOfPeriod: String?

    enum CodingKeys: String, CodingKey {
        case market
        case candleDateTimeUTC = "candle_date_time_utc"
        case candleDateTimeKst = "candle_date_time_kst"
        case openingPrice = "opening_price"
        case highPrice = "high_price"
        case lowPrice = "low_price"
        case tradePrice = "trade_price"
        case timestamp
        case candleAccTradePrice = "candle_acc_trade_price"
        case candleAccTradeVolume = "candle_acc_trade_volume"
        case prevClosingPrice = "prev_closing_price"
        case changePrice = "change_price"
        case changeRate = "change_rate"
        case unit
        case firstDayOfPeriod = "first_day_of_period"
    }
}

extension CandleData {
    
    var date: Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter.date(from: candleDateTimeUTC) ?? Date()
    }
}

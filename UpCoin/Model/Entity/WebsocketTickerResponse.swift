//
//  WebsocketTickerResponse.swift
//  UpStock
//
//  Created by 오국원 on 2023/08/01.
//

import Foundation

// MARK: - Welcome
struct WebsocketTickerResponse: Codable, Equatable {
        
    let type, code: String
    let openingPrice, highPrice, lowPrice, tradePrice, prevClosingPrice: Double
    let accTradePrice: Double
    let change: String
    let changePrice, signedChangePrice, changeRate, signedChangeRate: Double
    let askBid: String
    let tradeVolume, accTradeVolume: Double
    let tradeDate, tradeTime: String
    let tradeTimestamp: Int
    let accAskVolume, accBidVolume: Double
    let highest52_WeekPrice: Double
    let highest52_WeekDate: String
    let lowest52_WeekPrice: Double
    let lowest52_WeekDate, marketState: String
    let isTradingSuspended: Bool
    let delistingDate: JSONNull?
    let marketWarning: String
    let timestamp: Int
    let accTradePrice24H, accTradeVolume24H: Double
    let streamType: String
    
    enum CodingKeys: String, CodingKey {
        case type, code
        case openingPrice = "opening_price"
        case highPrice = "high_price"
        case lowPrice = "low_price"
        case tradePrice = "trade_price"
        case prevClosingPrice = "prev_closing_price"
        case accTradePrice = "acc_trade_price"
        case change
        case changePrice = "change_price"
        case signedChangePrice = "signed_change_price"
        case changeRate = "change_rate"
        case signedChangeRate = "signed_change_rate"
        case askBid = "ask_bid"
        case tradeVolume = "trade_volume"
        case accTradeVolume = "acc_trade_volume"
        case tradeDate = "trade_date"
        case tradeTime = "trade_time"
        case tradeTimestamp = "trade_timestamp"
        case accAskVolume = "acc_ask_volume"
        case accBidVolume = "acc_bid_volume"
        case highest52_WeekPrice = "highest_52_week_price"
        case highest52_WeekDate = "highest_52_week_date"
        case lowest52_WeekPrice = "lowest_52_week_price"
        case lowest52_WeekDate = "lowest_52_week_date"
        case marketState = "market_state"
        case isTradingSuspended = "is_trading_suspended"
        case delistingDate = "delisting_date"
        case marketWarning = "market_warning"
        case timestamp
        case accTradePrice24H = "acc_trade_price_24h"
        case accTradeVolume24H = "acc_trade_volume_24h"
        case streamType = "stream_type"
    }
}

extension WebsocketTickerResponse {
    
    static func ==(lhs: WebsocketTickerResponse, rhs: WebsocketTickerResponse) -> Bool {
        return lhs.code == rhs.code
    }
    
    func toTickerResponse() -> TickerResponse {
        return TickerResponse(
            market: self.code,
            tradeDate: self.tradeDate,
            tradeTime: self.tradeTime,
            tradeDateKst: "", // This field does not exist in WebsocketTickerResponse
            tradeTimeKst: "", // This field does not exist in WebsocketTickerResponse
            tradeTimestamp: self.tradeTimestamp,
            openingPrice: self.openingPrice,
            highPrice: self.highPrice,
            lowPrice: self.lowPrice,
            tradePrice: self.tradePrice,
            prevClosingPrice: self.prevClosingPrice,
            change: self.change,
            changePrice: self.changePrice,
            changeRate: self.changeRate,
            signedChangePrice: self.signedChangePrice,
            signedChangeRate: self.signedChangeRate,
            tradeVolume: self.tradeVolume,
            accTradePrice: self.accTradePrice,
            accTradePrice24H: self.accTradePrice24H,
            accTradeVolume: self.accTradeVolume,
            accTradeVolume24H: self.accTradeVolume24H,
            highest52_WeekPrice: self.highest52_WeekPrice,
            highest52_WeekDate: self.highest52_WeekDate,
            lowest52_WeekPrice: self.lowest52_WeekPrice,
            lowest52_WeekDate: self.lowest52_WeekDate,
            timestamp: self.timestamp
        )
    }
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {
    
    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }
    
    public var hashValue: Int {
        return 0
    }
    
    public init() {}
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

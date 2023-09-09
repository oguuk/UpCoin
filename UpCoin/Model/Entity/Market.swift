//
//  Market.swift
//  UpStock
//
//  Created by 오국원 on 2023/07/31.
//

import Foundation

typealias Markets = [Market]

struct Market: Codable {
    let market, koreanName, englishName: String

    enum CodingKeys: String, CodingKey {
        case market
        case koreanName = "korean_name"
        case englishName = "english_name"
    }
}

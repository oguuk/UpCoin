//
//  CandleAPIType.swift
//  UpStock
//
//  Created by 오국원 on 2023/08/27.
//

import Foundation

enum CandleAPIType: String {
    case day = "/days"
    case week = "/weeks"
    case month = "/months"
}
// 1, 3, 5, 15, 10, 30, 60, 240
enum AvailableMinutesUnit: String {
    case one = "/1"
    case three = "/3"
    case five = "/5"
    case fifteen = "/15"
    case thirty = "/30"
    case sixty = "/60"
    case twoHundredFourty = "/240"
}

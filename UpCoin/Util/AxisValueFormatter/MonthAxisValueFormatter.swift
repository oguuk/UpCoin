//
//  MonthAxisValueFormatter.swift
//  UpCoin
//
//  Created by oguuk on 2023/09/26.
//

import DGCharts
import Foundation

final class MonthAxisValueFormatter: NSObject, AxisValueFormatter {
    let dateFormatter: DateFormatter

    override init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM"
        super.init()
    }

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let date = Date(timeIntervalSince1970: value)
        return dateFormatter.string(from: date)
    }
}

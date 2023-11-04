//
//  TimeAxisValueFormatter.swift
//  UpCoin
//
//  Created by oguuk on 2023/09/21.
//

import DGCharts
import Foundation

class TimeAxisValueFormatter: NSObject, AxisValueFormatter {
    let dateFormatter: DateFormatter

    override init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        super.init()
    }

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let date = Date(timeIntervalSince1970: value)
        return dateFormatter.string(from: date)
    }
}

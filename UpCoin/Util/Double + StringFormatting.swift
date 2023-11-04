//
//  Double + StringFormatting.swift
//  UpStock
//
//  Created by 오국원 on 2023/07/31.
//

import Foundation

extension Double {
    
    var formattedWithSeparator: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: self)) ?? ""
    }
    
    func convertToMillionUnit() -> String {
        return (self / 1000000.0).toString() + "M"
    }
    
    func toString() -> String {
        return "\(self)"
    }
    
    func toPercentage(_ place: Int, _ multiply: Double = 1.0) -> String {
        return String(format: "%.\(place)f", self * multiply)
    }
    
    func miliSecondsToDate() -> (year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int) {
        let date = Date(timeIntervalSince1970: TimeInterval(self) / 1000.0) // 밀리초 단위를 초 단위로 바꿈

        let calendar = Calendar.current

        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
        return (year, month, day, hour, minute, second)
    }
}

//
//  Date + ISO8061.swift
//  UpCoin
//
//  Created by oguuk on 2023/09/22.
//

import Foundation

extension Date {
    
    var getISO8061Date: String {
        let date = Date() // 현재 날짜와 시간

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"

        let utcDateString = dateFormatter.string(from: date)
        print(utcDateString) // 예: 2023-01-01T00:00:00Z

        // KST (한국 표준시)로 변환
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 9 * 60 * 60)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXX"

        return dateFormatter.string(from: date)
    }
}

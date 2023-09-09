//
//  Double + StringFormatting.swift
//  UpStock
//
//  Created by 오국원 on 2023/07/31.
//

import Foundation

extension Double {
    
    func toPercentage(_ place: Int, _ multiply: Double = 1.0) -> String {
        return String(format: "%.\(place)f", self * multiply)
    }
}

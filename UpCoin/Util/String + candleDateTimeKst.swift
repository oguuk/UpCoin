//
//  String + candleDateTimeKst.swift
//  UpCoin
//
//  Created by oguuk on 2023/09/22.
//

import Foundation

extension String {
    
    var candleDateTimeKstToArray: [Double?] {
        return self.components(separatedBy: ["T", "-", ":"]).map { Double($0) }
    }
}

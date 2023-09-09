//
//  Dictionary + StringFormatting.swift
//  UpStock
//
//  Created by 오국원 on 2023/07/28.
//

import Foundation

extension Dictionary {
    
    func toPath() -> String {
        return "?" + self.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
    }
}

//
//  Identifiable1.swift
//  UpCoin
//
//  Created by oguuk on 2023/09/06.
//

import Foundation

protocol Identifiable {
    static var identifier: String { get }
}

extension Identifiable {
    static var identifier: String { return "\(self)" }
}

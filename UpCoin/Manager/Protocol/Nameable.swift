//
//  Nameable.swift
//  UpStock
//
//  Created by 오국원 on 2023/08/22.
//

import Foundation

protocol Nameable {
    var Market: String? { get }
    var KoreanName: String? { get }
    var EnglishName: String? { get }
}

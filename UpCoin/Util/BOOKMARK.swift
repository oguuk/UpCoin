//
//  BOOKMARK.swift
//  UpStock
//
//  Created by 오국원 on 2023/08/22.
//

import Foundation

extension BOOKMARK: Nameable {
    
    var Market: String? {
        return self.value(forKey: "market") as? String
    }
    
    var KoreanName: String? {
        return self.value(forKey: "koreanName") as? String
    }
    
    var EnglishName: String? {
        return self.value(forKey: "englishName") as? String
    }
}

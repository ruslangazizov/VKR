//
//  NSRegularExpression+Extensions.swift
//  VKR
//
//  Created by r.a.gazizov on 17.02.2024.
//

import Foundation

extension NSRegularExpression {
    
    func wholeMatches(_ string: String) -> Bool {
        let range = NSRange(location: 0, length: string.utf16.count)
        return firstMatch(in: string, range: range) != nil
    }
}

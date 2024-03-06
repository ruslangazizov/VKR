//
//  Trivia+Extensions.swift
//  VKR
//
//  Created by r.a.gazizov on 06.03.2024.
//

import SwiftSyntax

extension Trivia {
    
    static var indent: Trivia {
        Trivia.spaces(4)
    }
    
    static func indent(_ count: Int = 1) -> Trivia {
        Trivia.spaces(4 * count)
    }
}

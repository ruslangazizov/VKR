//
//  Array+Extensions.swift
//  VKR
//
//  Created by r.a.gazizov on 20.02.2024.
//

import Foundation

extension [ClassDeclSyntaxRef] {
    
    var names: [String] {
        return map {
            $0.value.name.text
        }
    }
    
    func first(className: String) -> ClassDeclSyntaxRef? {
        return first(where: { $0.value.name.text == className })
    }
}

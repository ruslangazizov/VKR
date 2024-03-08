//
//  String+Extensions.swift
//  VKR
//
//  Created by Руслан on 08.03.2024.
//

import Foundation

extension String {
    
    func splitByNewLineChar() -> [String] {
        self.split(separator: "\n", omittingEmptySubsequences: false).map { String($0) }
    }
}

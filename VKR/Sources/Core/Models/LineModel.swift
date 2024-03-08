//
//  LineModel.swift
//  VKR
//
//  Created by Руслан on 07.01.2024.
//

import Foundation

struct LineModel {
    enum Status {
        case added
        case removed
        case unchanged
        case empty
    }

    let text: String
    let line: Int?
    var status: Status
    
    init(text: String, line: Int? = Int.random(in: 1..<100), status: Status) {
        self.text = text
        self.line = line
        self.status = status
    }
}

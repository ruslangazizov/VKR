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
    let status: Status
}

//
//  FileChangesModel.swift
//  VKR
//
//  Created by Руслан on 14.02.2024.
//

import Foundation

struct FileChangesModel {
    let fileName: String
    let leftLines: [LineModel]
    let rightLines: [LineModel]
}

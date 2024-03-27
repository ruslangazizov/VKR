//
//  StatisticsModel.swift
//  VKR
//
//  Created by Руслан on 25.03.2024.
//

import Foundation

struct StatisticsModel {
    enum ImprovementOrder {
        case moreIsBetter
        case lessIsBetter
    }
    
    struct Row: Identifiable {
        let name: String
        let previousValue: Double
        let newValue: Double
        var improvementOrder: ImprovementOrder?
        
        var id: String {
            name
        }
    }
    
    let metrics: [Row]
    let formulas: [Row]
}

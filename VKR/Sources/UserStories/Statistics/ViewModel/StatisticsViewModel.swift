//
//  StatisticsViewModel.swift
//  VKR
//
//  Created by Руслан on 25.03.2024.
//

import Foundation

protocol IStatisticsViewModel: ObservableObject {
    var model: StatisticsModel { get }
}

final class StatisticsViewModel: IStatisticsViewModel {
    
    // Dependencies
    private let manager: SwiftFilesManager
    
    // Properties
    let model: StatisticsModel
    
    // MARK: - Initialization
    
    init(manager: SwiftFilesManager) {
        self.manager = manager
        model = StatisticsModel(metrics: [], formulas: [])
    }
}

//
//  StatisticsViewModelMock.swift
//  VKR
//
//  Created by Руслан on 25.03.2024.
//

import Foundation

final class StatisticsViewModelMock: IStatisticsViewModel {
    // TODO: формулы актуализировать правдоподобными значениями + пополнить их список
    // TODO: метрики можно отсортировать от наиболее к наименее значимым
    lazy var model = StatisticsModel(
        metrics: [
            StatisticsModel.Row(name: "CSLOC", previousValue: 58, newValue: 75),
            // Number of operations - counts the number of operations
            StatisticsModel.Row(name: "NOO", previousValue: 4, newValue: 4),
            // Weighted Method per class - is the sum of the complexity of all methods for a class
            StatisticsModel.Row(name: "WMC", previousValue: 1.5, newValue: 0.5, improvementOrder: .lessIsBetter),
            // Lack of Cohesion Metrics - is the number of pairs of methods in the class using no attribute in common, minus the number of pairs of methods that do. The LCOM is set to zero if this difference is negative.
            StatisticsModel.Row(name: "LCOM", previousValue: 16, newValue: 10, improvementOrder: .lessIsBetter),
            // Cohesion Among Methods of a Class
            StatisticsModel.Row(name: "CAMC", previousValue: 0.3, newValue: 0.3),
            // Coupling between objects - represents the number of other classes to which a class is coupled to
            StatisticsModel.Row(name: "CBO", previousValue: 4, newValue: 0, improvementOrder: .lessIsBetter),
            // Response for class - counts the number of methods in the response set for a class, which includes the number of methods in the class and the number of remote methods invoked by the methods in the class
            StatisticsModel.Row(name: "RFC", previousValue: 11, newValue: 11),
            // Depth of inheritance hierarchy - is the length of the inheritance chain from the root of the inheritance tree to the measured class
            StatisticsModel.Row(name: "DIT", previousValue: 4, newValue: 4, improvementOrder: .lessIsBetter),
            // Number of child classes - counts the number of classes directly or indirectly derived from the measured class
            StatisticsModel.Row(name: "NOC", previousValue: 0, newValue: 0),
            // Number of Methods Overridden - is the number of methods need to be re-declared by the inheriting class
            StatisticsModel.Row(name: "NMO", previousValue: 0, newValue: 0),
            // Number of test classes
            StatisticsModel.Row(name: "NTC", previousValue: 3, newValue: 3)
        ],
        formulas: [
            // Testability = -0.08 * Encapsulation + 1.12 * Inheritance + 0.97 * Coupling
            StatisticsModel.Row(name: "Khan & Mustafa", previousValue: 0.12, newValue: 0.46, improvementOrder: .moreIsBetter),
            // Testability = -483.65 + 300.92 * Understandability - 0.86 * Complexity
            // Understandability = 1.33515 + 0.12 * NAssoc + 0.0463 * NA + 0.3405 * MaxDIT
            // Complexity = 90.8488 + 10.5849 * Coupling - 102.7527 * Cohesion + 128.0856 * Inheritance
            StatisticsModel.Row(name: "Nazir Khan", previousValue: 87.48, newValue: 109.02, improvementOrder: .moreIsBetter),
            // Testability = -0.08 * NOO + 1.12 * DIT +(-) 0.97 * CBO
            StatisticsModel.Row(name: "M. Badri et. al.",
                                previousValue: -0.08 * 4 + 1.12 * 4 - 0.97 * 4,
                                newValue: -0.08 * 4 + 1.12 * 4 - 0.97 * 0,
                                improvementOrder: .moreIsBetter)
        ]
    )
}

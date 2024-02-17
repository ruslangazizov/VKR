//
//  Screen1Presenter.swift
//  VKR_Example
//
//  Created by r.a.gazizov on 15.02.2024.
//

import Foundation

protocol IScreen1Presenter: AnyObject {
    func viewDidLoad()
}

final class Screen1Presenter: IScreen1Presenter {
    
    // неявная зависимость на NetworkService
    private let networkService = NetworkService()
    
    func viewDidLoad() {
        networkService.sendRequest()
        let databaseService = DatabaseService()
    }
}

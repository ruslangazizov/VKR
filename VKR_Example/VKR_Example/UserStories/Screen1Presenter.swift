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
    
    // implicit dependency on NetworkService
    private let networkService = NetworkService()
    
    var s: String { "" }
    
    func viewDidLoad() {
        networkService.sendRequest()
        // implicit dependency on DatabaseService
        let databaseService = DatabaseService()
        let result = databaseService.saveSomething(someData: [1, 2, 3])
    }
}

class AnotherPresenter {
    
    private let screen1Presenter: Screen1Presenter
    private var someProperty = "someProperty"
    
    // implicit dependency on Screen1Presenter
    init(screen1Presenter: Screen1Presenter) {
        self.screen1Presenter = screen1Presenter
    }
    
    func someMethod() {
        screen1Presenter.viewDidLoad()
        let networkService = NetworkService()
        networkService.sendRequest()
    }
}

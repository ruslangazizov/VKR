import Foundation

class FirstClass {
    private let secondClass: SecondClass
    
    // implicit dependency on Screen1Presenter
    init(secondClass: SecondClass) {
        self.secondClass = secondClass
    }
    
    func firstClassMethod1() {
        secondClass.secondClassMethod1()
        // implicit dependency on NetworkService
        let networkService = NetworkService()
        networkService.sendRequest()
    }
    
    func firstClassMethod2() {
        _ = secondClass.secondClassProperty1
        _ = secondClass.secondClassProperty2
    }
}

class SecondClass {
    // implicit dependency on NetworkService
    private let networkService = NetworkService()
    
    func secondClassMethod1() {
        networkService.sendRequest()
        // implicit dependency on DatabaseService
        let databaseService = DatabaseService()
        _ = databaseService.saveSomething(someData: [1, 2, 3])
    }
    
    var secondClassProperty1: String {
        "Hello, world!"
    }
    
    public var secondClassProperty2: Int = 1
}

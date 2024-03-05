import Foundation

class DatabaseService {
    // implicit dependency on UserDefaults.standard
    let defaults = UserDefaults.standard
    
    func saveSomething(someData: [Int]) -> String {
        return ""
    }
}

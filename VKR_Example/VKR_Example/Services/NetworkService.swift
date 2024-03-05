import Foundation

class NetworkService {
    func sendRequest() {
        guard let url = URL(string: "www.google.com") else {
            return
        }
        
        // implicit dependency on URLSession.shared
        let task = URLSession.shared.dataTask(
            with: URLRequest(url: url)
        ) { data, response, error in
            // some logic
        }
        task.resume()
    }
}

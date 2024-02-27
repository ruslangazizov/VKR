//
//  NetworkService.swift
//  VKR_Example
//
//  Created by r.a.gazizov on 15.02.2024.
//

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

//
//  NetworkService.swift
//  VKR_Example
//
//  Created by r.a.gazizov on 15.02.2024.
//

import Foundation

final class NetworkService {
    
    func sendRequest() {
        guard let url = URL(string: "www.google.com") else {
            return
        }
        
        // неявная зависимость на URLSession.shared
        let task = URLSession.shared.dataTask(
            with: URLRequest(url: url)
        ) { data, response, error in
            // какая-то логика
        }
        task.resume()
    }
}

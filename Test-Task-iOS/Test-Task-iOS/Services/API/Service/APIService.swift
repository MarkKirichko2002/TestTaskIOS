//
//  APIService.swift
//  Test-Task-iOS
//
//  Created by Марк Киричко on 20.11.2025.
//

import Foundation

protocol IAPIService: AnyObject {
    func getPosts(page: Int, limit: Int, completion: @escaping([Post])->Void)
}

final class APIService: IAPIService {
    
    func getPosts(page: Int, limit: Int, completion: @escaping([Post])->Void) {
        URLSession.shared.dataTask(with: URLRequest(url: URL(string: "https://jsonplaceholder.typicode.com/posts?_page=\(page)&_limit=\(limit)")!)) { data, response, error in
            if let error = error {
                print(error)
            } else {
                guard let data = data else {return}
                do {
                    let data = try JSONDecoder().decode([Post].self, from: data)
                    completion(data)
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
}

//
//  HTTPClient.swift
//  HTTPUtility
//
//  Created by Eshan on 08/07/25.
//

import Foundation

enum HTTPError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(Error)
}

class HTTPClient {
    static let shared = HTTPClient()
    private init() {}
    
    func fetchData<T: Decodable>(
        from urlString: String,
        responseType: T.Type,
        completion: @escaping (Result<T, HTTPError>) -> Void
    ) {
        // 1. Create URL
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        // 2. Create URLRequest
        let request = URLRequest(url: url)
        
        // 3. Perform request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.requestFailed(error)))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(.invalidResponse))
                }
                return
            }
            
            // 4. Decode data
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(decodedData))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.decodingFailed(error)))
                }
            }
        }
        
        task.resume()
    }
    
    /// Fetch data from API and decode into a Codable model
    func fetchData<T: Decodable>(
        urlString: String,
        headers: [String: String] = [:],
        responseType: T.Type,
        completion: @escaping (Result<T, HTTPError>) -> Void
    ) {
        // 1. Create URL
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        // 2. Create URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // 3. Add headers
        headers.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        // 4. Perform request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            // 5. Handle error
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.requestFailed(error)))
                }
                return
            }
            
            // 6. Validate response and data
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(.invalidResponse))
                }
                return
            }
            
            // 7. Decode data into model
            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(decodedResponse))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.decodingFailed(error)))
                }
            }
        }
        
        task.resume()
    }
}


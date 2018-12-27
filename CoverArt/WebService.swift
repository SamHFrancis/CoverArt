//
//  WebService.swift
//  CoverArt
//
//  Created by Sam Francis on 12/27/18.
//  Copyright © 2018 SamFrancis. All rights reserved.
//

import Foundation

fileprivate let host = "itunes.apple.com"

struct WebService {
    
    static func fetchMediaItems(term: String, completion: @escaping ((Result<[MediaItem], ServiceError>) -> ())) {
        var components = URLComponents()
        components.host = host
        components.scheme = "https"
        components.path = "/search"
        components.queryItems = [URLQueryItem(name: "entity", value: "movie"),
                                 URLQueryItem(name: "term", value: term)]
        
        guard let url = components.url else {
            completion(.failure(.url))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                if let error = error {
                    completion(.failure(.requestError(error)))
                } else {
                    completion(.failure(.unknown))
                }
                return
            }
            
            guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
                let results = json?["results"] as? [[String: Any]] else {
                    completion(.failure(.parsing))
                    return
            }
            
            do {
                let mediaItems = try results.map(MediaItem.init)
                completion(.success(mediaItems))
            } catch let error as ServiceError {
                completion(.failure(error))
            } catch {
                completion(.failure(.unknown))
            }
        }
        
        task.resume()
    }
}


enum ServiceError: Error {
    case parsing
    case url
    case requestError(Error)
    case unknown
}

enum Result<Value, E: Error> {
    case success(Value)
    case failure(E)
}

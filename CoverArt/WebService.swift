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
    
    static func fetchMediaItems(term: String, mediaType: MediaType, completion: @escaping ((Result<[MediaItem], ServiceError>) -> ())) {
        var components = URLComponents()
        components.host = host
        components.scheme = "https"
        components.path = "/search"
        components.queryItems = [URLQueryItem(name: "media", value: mediaType.rawValue),
                                 URLQueryItem(name: "term", value: term)]
        
        var entity: String?
        switch mediaType {
        case .tvShow:
            entity = "tvSeason"
        case .music:
            entity = "album"
        default:
            break
        }
        
        if let entity = entity {
            components.queryItems?.append(URLQueryItem(name: "entity", value: entity))
        }
        
        guard let url = components.url else {
            completion(.failure(.url))
            return
        }
        
        
//        print("APILog: " + url.absoluteString)
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                if let error = error {
                    completion(.failure(.requestError(error)))
                } else {
                    completion(.failure(.unknown))
                }
                return
            }
            
//            print("APILog: " + (String(data: data, encoding: .utf8) ?? ""))
            
            guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
                let results = json?["results"] as? [[String: Any]] else {
                    completion(.failure(.parsing))
                    return
            }
            
            let mediaItems = results.compactMap { MediaItem(dict: $0, type: mediaType) }
            completion(.success(mediaItems))
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

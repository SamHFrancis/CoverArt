//
//  MediaItem.swift
//  CoverArt
//
//  Created by Sam Francis on 12/27/18.
//  Copyright © 2018 SamFrancis. All rights reserved.
//

import Foundation

struct MediaItem {
    let trackName: String
    let artworkUrl: String
    
    init(dict: [String: Any]) throws {
        guard let trackName = dict["trackName"] as? String,
            let artworkUrl100 = dict["artworkUrl100"] as? String else {
                throw ServiceError.parsing
        }
        
        var artworkUrlComponents = URLComponents(string: artworkUrl100)
        guard let path = artworkUrlComponents?.path else { throw ServiceError.parsing }
        
        artworkUrlComponents?.path = path.replacingOccurrences(of: "100x100bb", with: "100000x100000-999")
        artworkUrlComponents?.host = "is5.mzstatic.com"
        artworkUrlComponents?.scheme = "http"
        
        guard let artworkUrl = artworkUrlComponents?.url?.absoluteString else { throw ServiceError.parsing }
        
        self.trackName = trackName
        self.artworkUrl = artworkUrl
    }
}

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
    let artworkUrlSmall: URL
    let artworkUrl: URL
    
    init?(dict: [String: Any]) {
        guard let trackName = (dict["trackName"] ?? dict["collectionName"]) as? String,
            let artworkUrl100 = dict["artworkUrl100"] as? String else {
                return nil
        }
        
        var artworkUrlComponents = URLComponents(string: artworkUrl100)
        
        guard let smallPath = artworkUrlComponents?.path else {
            return nil
        }
        
        artworkUrlComponents?.path = smallPath.replacingOccurrences(of: "100x100bb", with: "600x600bb")
        
        guard let smallUrl = artworkUrlComponents?.url,
            let path = artworkUrlComponents?.path else {
                return nil
        }
        
        self.artworkUrlSmall = smallUrl
        
        artworkUrlComponents?.path = path.replacingOccurrences(of: "600x600bb", with: "100000x100000-999")
        artworkUrlComponents?.host = "is5.mzstatic.com"
        artworkUrlComponents?.scheme = "http"
        
        guard let artworkUrl = artworkUrlComponents?.url else { return nil }
        
        self.trackName = trackName
        self.artworkUrl = artworkUrl
    }
}

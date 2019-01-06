//
//  MediaType.swift
//  CoverArt
//
//  Created by Sam Francis on 12/28/18.
//  Copyright © 2018 SamFrancis. All rights reserved.
//

import Foundation

enum MediaType: String, CaseIterable {
    case movie, tvShow, podcast, music, musicVideo, audiobook, software, ebook
    
    var displayString: String {
        switch self {
        case .movie:
            return "Movie"
        case .podcast:
            return "Podcast"
        case .music:
            return "Music"
        case .musicVideo:
            return "Music Video"
        case .audiobook:
            return "Audiobook"
        case .tvShow:
            return "TV Show"
        case .software:
            return "Software"
        case .ebook:
            return "eBook"
        }
    }
    
}

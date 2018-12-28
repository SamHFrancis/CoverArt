//
//  MediaType.swift
//  CoverArt
//
//  Created by Sam Francis on 12/28/18.
//  Copyright © 2018 SamFrancis. All rights reserved.
//

import Foundation

enum MediaType: String, CaseIterable {
    case movie, tvShow, podcast, music, musicVideo, audiobook, shortFilm, software, ebook
    
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
        case .shortFilm:
            return "Short Film"
        case .tvShow:
            return "TV Show"
        case .software:
            return "Software"
        case .ebook:
            return "eBook"
        }
    }
    
    var imageAspectRatio: CGFloat {
        switch self {
        case .movie, .shortFilm, .software, .ebook:
            return 2.0/3.0
        default:
            return 1
        }
    }
    
}
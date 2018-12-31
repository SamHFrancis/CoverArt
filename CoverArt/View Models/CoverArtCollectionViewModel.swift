//
//  CoverArtCollectionViewModel.swift
//  CoverArt
//
//  Created by Sam Francis on 12/31/18.
//  Copyright © 2018 SamFrancis. All rights reserved.
//

import Foundation

final class CoverArtCollectionViewModel {
    private let mediaItem: MediaItem
    var isDownloading = false
    
    init(mediaItem: MediaItem) {
        self.mediaItem = mediaItem
    }
    
    var trackName: String {
        return mediaItem.trackName
    }
    
    var artworkUrlSmall: URL {
        return mediaItem.artworkUrlSmall
    }
    
    var artworkUrl: URL {
        return mediaItem.artworkUrl
    }
    
    var imageAspectRatio: CGFloat {
        switch mediaItem.type {
        case .movie, .shortFilm, .ebook:
            return 2/3
        default:
            return 1
        }
    }
}

//
//  CoverArtCollectionViewModel.swift
//  CoverArt
//
//  Created by Sam Francis on 12/31/18.
//  Copyright © 2018 SamFrancis. All rights reserved.
//

import Foundation
import AppKit

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
        case .movie, .ebook:
            return 2/3
        default:
            return 1
        }
    }
    
    var placeholderImage: NSImage {
        switch mediaItem.type {
        case .movie:
            return #imageLiteral(resourceName: "movie")
        case .tvShow:
            return #imageLiteral(resourceName: "tv_show")
        case .podcast:
            return #imageLiteral(resourceName: "podcast")
        case .music:
            return #imageLiteral(resourceName: "music")
        case .musicVideo:
            return #imageLiteral(resourceName: "music_video")
        case .audiobook:
            return #imageLiteral(resourceName: "audiobook")
        case .software:
            return #imageLiteral(resourceName: "software")
        case .ebook:
            return #imageLiteral(resourceName: "ebook")
        }
    }
}

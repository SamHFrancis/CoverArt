//
//  CoverArtCollectionViewModel.swift
//  CoverArt
//
//  Created by Sam Francis on 12/31/18.
//  Copyright © 2018 SamFrancis. All rights reserved.
//

import Foundation
import AppKit
import Kingfisher

final class CoverArtCollectionViewModel {
    private let mediaItem: MediaItem
    var isDownloading = false
    var downloadTask: URLSessionDataTask?
    
    init(mediaItem: MediaItem) {
        self.mediaItem = mediaItem
    }
    
    var trackName: String {
        return mediaItem.name
    }
    
    var artworkUrlSmall: URL {
        return mediaItem.artworkUrlSmall
    }
    
    var artworkUrl: URL {
        return mediaItem.artworkUrl
    }
    
    var imageResource: ImageResource {
        return ImageResource(downloadURL: mediaItem.artworkUrlSmall, cacheKey: String(mediaItem.id))
    }
    
    var imageAspectRatio: CGFloat {
        switch mediaItem.type {
        case .movie, .ebook:
            return 2/3
        default:
            return 1
        }
    }
    
    private(set) lazy var downSamplingImageProcessor: ImageProcessor = {
        let size = CGSize(width: 420, height: 420 / self.imageAspectRatio)
        return DownsamplingImageProcessor(size: size)
    }()
    
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
    
    func downloadArtwork(completion: @escaping ((Result<Void, ServiceError>) -> ())) {
        isDownloading = true
        downloadTask = WebService.downloadArtwork(mediaItem: mediaItem) { [weak self] result in
            self?.isDownloading = false
            completion(result)
        }
    }
    
    deinit {
        downloadTask?.cancel()
    }
}

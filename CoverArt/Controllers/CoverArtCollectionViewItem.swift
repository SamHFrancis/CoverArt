//
//  CoverArtCollectionViewItem.swift
//  ArtCollectionView
//
//  Created by Samuel Francis on 12/27/18.
//  Copyright © 2018 SamFrancis. All rights reserved.
//

import Cocoa
import Kingfisher

final class CoverArtCollectionViewItem: NSCollectionViewItem {
    
    private let label: NSTextField = {
        let label = NSTextField(labelWithString: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .labelColor
        label.font = NSFont.systemFont(ofSize: 15, weight: .medium)
        label.lineBreakMode = .byTruncatingTail
        label.isSelectable = true
        return label
    }()
    
    private var coverArtImageView: NSImageView = {
        let imageView = NSImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.imageScaling = .scaleProportionallyUpOrDown
        return imageView
    }()
    
    private let overlay: OverlayView = {
        let overlay = OverlayView()
        overlay.translatesAutoresizingMaskIntoConstraints = false
        return overlay
    }()
    
    var imageHeightConstraint: NSLayoutConstraint!
    
    override var representedObject: Any? {
        didSet {
            guard let mediaItem = representedObject as? MediaItem else {
                return
            }
            
            label.stringValue = mediaItem.trackName
            
            imageHeightConstraint.isActive = false
            imageHeightConstraint = coverArtImageView.heightAnchor
                .constraint(equalTo: coverArtImageView.widthAnchor,
                            multiplier: 1.0 / mediaItem.type.imageAspectRatio)
            imageHeightConstraint.isActive = true
            
            let size = CGSize(width: 420, height: 420 / mediaItem.type.imageAspectRatio)
            let processor = DownsamplingImageProcessor(size: size)
            coverArtImageView.kf.indicatorType = .activity
            let options: KingfisherOptionsInfo = [
                .processor(processor),
                .scaleFactor(NSScreen.main!.backingScaleFactor),
                .cacheMemoryOnly
            ]
            
            coverArtImageView.kf.setImage(with: mediaItem.artworkUrlSmall,
                                          options: options)
            overlay.showCopy()
        }
    }
    
    private var mediaItem: MediaItem? {
        return representedObject as? MediaItem
    }
    
    override func loadView() {
        let view = NSView(frame: .zero)
        
        view.addSubview(coverArtImageView)
        coverArtImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        coverArtImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        coverArtImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        imageHeightConstraint = coverArtImageView.heightAnchor
            .constraint(equalTo: coverArtImageView.widthAnchor)
        imageHeightConstraint.isActive = true
        
        view.addSubview(label)
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor).isActive = true
        
        view.addSubview(overlay)
        overlay.topAnchor.constraint(equalTo: coverArtImageView.topAnchor).isActive = true
        overlay.bottomAnchor.constraint(equalTo: coverArtImageView.bottomAnchor).isActive = true
        overlay.leadingAnchor.constraint(equalTo: coverArtImageView.leadingAnchor).isActive = true
        overlay.trailingAnchor.constraint(equalTo: coverArtImageView.trailingAnchor).isActive = true
        overlay.delegate = self
        
        self.view = view
    }
}

extension CoverArtCollectionViewItem: OverlayDelegate {
    func overlayClicked() {
        guard let artworkUrl = mediaItem?.artworkUrl else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(artworkUrl.absoluteString, forType: .string)
        overlay.showCopied()
    }
}

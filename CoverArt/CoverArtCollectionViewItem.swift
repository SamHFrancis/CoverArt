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
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    private var coverArtImageView: NSImageView = {
        let imageView = NSImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setContentHuggingPriority(.defaultLow, for: .vertical)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        imageView.imageScaling = .scaleProportionallyUpOrDown
        return imageView
    }()
    
    private let overlay: OverlayView = {
        let overlay = OverlayView()
        overlay.translatesAutoresizingMaskIntoConstraints = false
        return overlay
    }()
    
    private var trackingArea: NSTrackingArea?
    
    override var representedObject: Any? {
        didSet {
            guard let mediaItem = representedObject as? MediaItem else {
                return
            }
            
            label.stringValue = mediaItem.trackName
            let processor = DownsamplingImageProcessor(size: CGSize(width: 200, height: 300))
            coverArtImageView.kf.indicatorType = .activity
            let options: KingfisherOptionsInfo = [
                .processor(processor),
                .scaleFactor(NSScreen.main!.backingScaleFactor),
                .cacheMemoryOnly
            ]
            
            coverArtImageView.kf.setImage(with: mediaItem.artworkUrlSmall,
                                          options: options)
            overlay.isHidden = true
            overlay.showCopy()
        }
    }
    
    private var mediaItem: MediaItem? {
        return representedObject as? MediaItem
    }
    
    override func loadView() {
        let view = NSView(frame: .zero)
        
        let stackView = NSStackView(views: [coverArtImageView, label])
        stackView.orientation = .vertical
        stackView.alignment = .leading
        stackView.spacing = 8
        coverArtImageView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
        coverArtImageView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true
        
        view.addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        view.addSubview(overlay)
        overlay.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        overlay.isHidden = true
        
        self.view = view
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        
        if let currentTrackingArea = trackingArea {
            view.removeTrackingArea(currentTrackingArea)
        }
        
        let newTrackingArea = NSTrackingArea(rect: view.bounds, options: [.mouseEnteredAndExited, .activeInActiveApp], owner: self, userInfo: nil)
        view.addTrackingArea(newTrackingArea)
        
        trackingArea = newTrackingArea
    }
    
    override func mouseEntered(with event: NSEvent) {
        overlay.isHidden = false
    }
    
    override func mouseExited(with event: NSEvent) {
        overlay.isHidden = true
        overlay.showCopy()
    }
    
    override func mouseUp(with event: NSEvent) {
        guard let artworkUrl = mediaItem?.artworkUrl else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(artworkUrl.absoluteString, forType: .string)
        overlay.showCopied()
    }
}

fileprivate final class OverlayView: NSView {
    
    private let label = { () -> NSTextField in
        let label = NSTextField(labelWithString: "Copy URL")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = NSFont.systemFont(ofSize: 18, weight: .medium)
        return label
    } ()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(label)
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        NSColor.black.withAlphaComponent(0.75).setFill()
        dirtyRect.fill()
    }
    
    func showCopied() {
        label.stringValue = "Copied ✅"
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { [weak self] _ in
            self?.label.stringValue = "Copy URL"
        }
    }
    
    func showCopy() {
        label.stringValue = "Copy URL"
    }
    
}

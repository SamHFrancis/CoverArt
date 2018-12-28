//
//  CoverArtCollectionViewItem.swift
//  ArtCollectionView
//
//  Created by Samuel Francis on 12/27/18.
//  Copyright © 2018 SamFrancis. All rights reserved.
//

import Cocoa

class CoverArtCollectionViewItem: NSCollectionViewItem {
    
    let label = { () -> NSTextField in
        let label = NSTextField(labelWithString: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    let overlay = { () -> OverlayView in
        let overlay = OverlayView()
        overlay.translatesAutoresizingMaskIntoConstraints = false
        return overlay
    }()
    
    var trackingArea: NSTrackingArea?
    
    override var representedObject: Any? {
        didSet {
            guard let mediaItem = representedObject as? MediaItem else {
                return
            }
            
            label.stringValue = mediaItem.trackName
            overlay.isHidden = true
            overlay.showCopy()
        }
    }
    
    var mediaItem: MediaItem? {
        return representedObject as? MediaItem
    }
    
    override func loadView() {
        let view = NSView(frame: .zero)
        view.addSubview(label)
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
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
        NSPasteboard.general.setString(artworkUrl, forType: .string)
        overlay.showCopied()
    }
}

class OverlayView: NSView {
    
    let label = { () -> NSTextField in
        let label = NSTextField(labelWithString: "Copy URL")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
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
    
    func commonInit() {
        addSubview(label)
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        NSColor.red.withAlphaComponent(0.4).setFill()
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

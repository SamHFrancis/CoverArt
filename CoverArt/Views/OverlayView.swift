//
//  OverlayView.swift
//  CoverArt
//
//  Created by Sam Francis on 12/29/18.
//  Copyright © 2018 SamFrancis. All rights reserved.
//

import Cocoa

protocol OverlayDelegate: class {
    func copyLinkClicked()
    func browserClicked()
    func downloadClicked()
}

final class OverlayView: NSView {
    
    weak var delegate: OverlayDelegate?
    
    private var trackingArea: NSTrackingArea?
    
    private let contentView: ContentView = {
        let overlayView = ContentView()
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        return overlayView
    }()
    
    private let copyButton: NSButton = {
        let button = NSButton(image: #imageLiteral(resourceName: "link"), target: nil, action: nil)
        button.toolTip = "Copy Link"
        button.setContentHuggingPriority(.defaultLow, for: .horizontal)
        button.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return button
    }()
    
    private let browserButton: NSButton = {
        let button = NSButton(image: #imageLiteral(resourceName: "browser"), target: nil, action: nil)
        button.toolTip = "Open in Browser"
        button.setContentHuggingPriority(.defaultLow, for: .horizontal)
        button.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return button
    }()
    
    private let downloadButton: NSButton = {
        let button = NSButton(image: #imageLiteral(resourceName: "download"), target: nil, action: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.toolTip = "Download"
        button.setContentHuggingPriority(.defaultLow, for: .horizontal)
        button.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return button
    }()
    
    let progerssIndicator: NSProgressIndicator = {
        let indicator = NSProgressIndicator()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.controlSize = .mini
        indicator.isIndeterminate = true
        indicator.style = .spinning
        indicator.isDisplayedWhenStopped = false
        return indicator
    }()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(contentView)
        contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        contentView.isHidden = true
        
        let downloadView = NSView()
        downloadView.translatesAutoresizingMaskIntoConstraints = false
        downloadView.addSubview(downloadButton)
        downloadButton.topAnchor.constraint(equalTo: downloadView.topAnchor).isActive = true
        downloadButton.bottomAnchor.constraint(equalTo: downloadView.bottomAnchor).isActive = true
        downloadButton.leadingAnchor.constraint(equalTo: downloadView.leadingAnchor).isActive = true
        downloadButton.trailingAnchor.constraint(equalTo: downloadView.trailingAnchor).isActive = true
        
        downloadView.addSubview(progerssIndicator)
        progerssIndicator.centerXAnchor.constraint(equalTo: downloadView.centerXAnchor).isActive = true
        progerssIndicator.centerYAnchor.constraint(equalTo: downloadView.centerYAnchor).isActive = true
        
        let buttonStack = NSStackView(views: [copyButton, browserButton, downloadView])
        buttonStack.distribution = .fillEqually
        buttonStack.orientation = .horizontal
        buttonStack.alignment = .centerY
        
        contentView.addSubview(buttonStack)
        buttonStack.leadingAnchor
            .constraint(equalTo: contentView.leadingAnchor, constant: 12)
            .isActive = true
        
        buttonStack.trailingAnchor
            .constraint(equalTo: contentView.trailingAnchor, constant: -12)
            .isActive = true
        
        buttonStack.bottomAnchor
            .constraint(equalTo: contentView.bottomAnchor, constant: -12)
            .isActive = true
        
        copyButton.target = self
        copyButton.action = #selector(copyClicked)
        
        browserButton.target = self
        browserButton.action = #selector(browserClicked)
        
        downloadButton.target = self
        downloadButton.action = #selector(downloadClicked)
        
    }
    
    override func layout() {
        super.layout()
        if let currentTrackingArea = trackingArea {
            removeTrackingArea(currentTrackingArea)
        }
        
        let newTrackingArea = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeInActiveApp], owner: self, userInfo: nil)
        addTrackingArea(newTrackingArea)
        
        trackingArea = newTrackingArea
    }
    
    func showCopied() {
        progerssIndicator.stopAnimation(nil)
        copyButton.image = #imageLiteral(resourceName: "check")
    }
    
    func showDownloaded() {
        progerssIndicator.stopAnimation(nil)
        downloadButton.isHidden = false
        downloadButton.image = #imageLiteral(resourceName: "check")
    }
    
    func showDownloading() {
        downloadButton.isHidden = true
        progerssIndicator.startAnimation(nil)
    }
    
    func resetCopyButton() {
        self.copyButton.image = #imageLiteral(resourceName: "link")
    }
    
    func resetDownloadButton() {
        progerssIndicator.stopAnimation(nil)
        downloadButton.isHidden = false
        self.downloadButton.image = #imageLiteral(resourceName: "download")
    }
    
    @objc func copyClicked() {
        delegate?.copyLinkClicked()
    }
    
    @objc func browserClicked() {
        delegate?.browserClicked()
    }
    
    @objc func downloadClicked() {
        delegate?.downloadClicked()
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.25
            context.allowsImplicitAnimation = true
            contentView.isHidden = false
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.25
            context.allowsImplicitAnimation = true
            contentView.isHidden = true
        }
        
        resetCopyButton()
        resetDownloadButton()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.isHidden = true
        resetCopyButton()
        resetDownloadButton()
    }
    
    private final class ContentView: NSView {
        override func draw(_ dirtyRect: NSRect) {
            super.draw(dirtyRect)
            if let gradient = NSGradient(colors: [.clear, .clear, .clear, NSColor.black.withAlphaComponent(0.8)]),
                dirtyRect.origin == .zero {
                gradient.draw(in: dirtyRect, angle: 270)
                print(dirtyRect)
            }
        }
    }
    
}

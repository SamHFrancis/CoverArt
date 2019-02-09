//
//  CoverArtCollectionViewItem.swift
//  ArtCollectionView
//
//  Created by Samuel Francis on 12/27/18.
//  Copyright © 2018 SamFrancis. All rights reserved.
//

import Cocoa
import Foundation
import Kingfisher

final class CoverArtCollectionViewItem: NSCollectionViewItem {
    
    //MARK: - Subviews
    
    private let label: NSTextField = {
        let label = NSTextField(labelWithString: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .labelColor
        label.font = NSFont.systemFont(ofSize: 15, weight: .medium)
        label.lineBreakMode = .byTruncatingTail
        label.isSelectable = true
        return label
    }()
    
    private var coverArtImageView: CoverImageView = {
        let imageView = CoverImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.imageScaling = .scaleProportionallyUpOrDown
        return imageView
    }()
    
    private let overlay: OverlayView = {
        let overlay = OverlayView()
        overlay.translatesAutoresizingMaskIntoConstraints = false
        return overlay
    }()
    
    let contentView: NSView = {
        let overlayView = ContentView()
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        return overlayView
    }()
    
    private let copyButton: NSButton = {
        let button = NSButton(image: #imageLiteral(resourceName: "link"), target: nil, action: nil)
        button.toolTip = "Copy Link"
        return button
    }()
    
    private let browserButton: NSButton = {
        let button = NSButton(image: #imageLiteral(resourceName: "browser"), target: nil, action: nil)
        button.toolTip = "Open in Browser"
        return button
    }()
    
    private let downloadButton: NSButton = {
        let button = NSButton(image: #imageLiteral(resourceName: "download"), target: nil, action: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.toolTip = "Download"
        return button
    }()
    
    private let progerssIndicator: NSProgressIndicator = {
        let indicator = NSProgressIndicator()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.controlSize = .mini
        indicator.isIndeterminate = true
        indicator.style = .spinning
        indicator.isDisplayedWhenStopped = false
        
        let colorFilter = CIFilter(name: "CIFalseColor")!
        colorFilter.setDefaults()
        colorFilter.setValue(CIColor(color: .white), forKey: "inputColor0")
        colorFilter.setValue(CIColor(color: .white), forKey: "inputColor1")
        indicator.contentFilters = [colorFilter]
        return indicator
    }()
    
    //MARK: - Properties
    
    var imageHeightConstraint: NSLayoutConstraint!
    
    override var representedObject: Any? {
        didSet {
            guard let viewModel = representedObject as? CoverArtCollectionViewModel else {
                return
            }
            
            label.stringValue = viewModel.trackName
            
            imageHeightConstraint.isActive = false
            imageHeightConstraint = coverArtImageView.heightAnchor
                .constraint(equalTo: coverArtImageView.widthAnchor,
                            multiplier: 1.0 / viewModel.imageAspectRatio)
            imageHeightConstraint.isActive = true
            
            let options: KingfisherOptionsInfo = [
                .scaleFactor(NSScreen.main!.backingScaleFactor),
                .cacheMemoryOnly,
                .onFailureImage(viewModel.placeholderImage)
            ]
            
            coverArtImageView.kf.setImage(with: .network(viewModel.imageResource),
                                          placeholder: viewModel.placeholderImage,
                                          options: options)
            resetCopyButton()
        }
    }
    
    private var viewModel: CoverArtCollectionViewModel? {
        return representedObject as? CoverArtCollectionViewModel
    }
    
    //MARK: - Life Cycle
    
    override func loadView() {
        let view = NSView(frame: .zero)
        
        view.addSubview(coverArtImageView)
        view.addSubview(label)
        
        let downloadView = NSView()
        downloadView.translatesAutoresizingMaskIntoConstraints = false
        downloadView.addSubview(downloadButton)
        downloadView.addSubview(progerssIndicator)
        
        let buttonStack = NSStackView(views: [copyButton, browserButton, downloadView])
        buttonStack.distribution = .fillEqually
        buttonStack.orientation = .horizontal
        buttonStack.alignment = .centerY
        contentView.addSubview(buttonStack)
        
        overlay.addSubview(contentView)
        view.addSubview(overlay)
        
        imageHeightConstraint = coverArtImageView.heightAnchor
            .constraint(equalTo: coverArtImageView.widthAnchor)
        
        NSLayoutConstraint.activate([
            imageHeightConstraint,
            coverArtImageView.topAnchor.constraint(equalTo: view.topAnchor),
            coverArtImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            coverArtImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: overlay.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: overlay.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: overlay.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: overlay.trailingAnchor),
            
            downloadButton.topAnchor.constraint(equalTo: downloadView.topAnchor),
            downloadButton.bottomAnchor.constraint(equalTo: downloadView.bottomAnchor),
            downloadButton.leadingAnchor.constraint(equalTo: downloadView.leadingAnchor),
            downloadButton.trailingAnchor.constraint(equalTo: downloadView.trailingAnchor),
            
            progerssIndicator.centerXAnchor.constraint(equalTo: downloadView.centerXAnchor),
            progerssIndicator.centerYAnchor.constraint(equalTo: downloadView.centerYAnchor),
            
            buttonStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            buttonStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            buttonStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            overlay.topAnchor.constraint(equalTo: coverArtImageView.topAnchor),
            overlay.bottomAnchor.constraint(equalTo: coverArtImageView.bottomAnchor),
            overlay.leadingAnchor.constraint(equalTo: coverArtImageView.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: coverArtImageView.trailingAnchor)
            ])
        
        contentView.isHidden = true
        
        copyButton.target = self
        copyButton.action = #selector(copyLinkClicked)
        
        browserButton.target = self
        browserButton.action = #selector(browserClicked)
        
        downloadButton.target = self
        downloadButton.action = #selector(downloadClicked)
        
        overlay.delegate = self
        
        self.view = view
    }
    
    //MARK: - View States
    
    func showCopied() {
        progerssIndicator.stopAnimation(nil)
        copyButton.image = #imageLiteral(resourceName: "check")
    }
    
    func showDownloaded() {
        progerssIndicator.stopAnimation(nil)
        downloadButton.isHidden = false
        downloadButton.image = #imageLiteral(resourceName: "check")
    }
    
    func showDownloadError() {
        progerssIndicator.stopAnimation(nil)
        downloadButton.isHidden = false
        downloadButton.image = #imageLiteral(resourceName: "error")
    }
    
    func showDownloading() {
        downloadButton.isHidden = true
        progerssIndicator.startAnimation(nil)
    }
    
    func resetCopyButton() {
        copyButton.image = #imageLiteral(resourceName: "link")
    }
    
    func resetDownloadButton() {
        guard let viewModel = viewModel else { return }
        
        if viewModel.isDownloading {
            showDownloading()
        } else {
            progerssIndicator.stopAnimation(nil)
            downloadButton.isHidden = false
            downloadButton.image = #imageLiteral(resourceName: "download")
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.isHidden = true
        resetCopyButton()
        resetDownloadButton()
    }
    
    //MARK: - Actions
    
    @objc func downloadClicked() {
        guard let viewModel = viewModel else { return }
        
        showDownloading()
        viewModel.downloadArtwork { result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success():
                    self?.showDownloaded()
                case .failure(_):
                    self?.showDownloadError()
                }
            }
        }
    }
    
    @objc func copyLinkClicked() {
        guard let artworkUrl = viewModel?.artworkUrl else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(artworkUrl.absoluteString, forType: .string)
        showCopied()
    }
    
    @objc func browserClicked() {
        guard let artworkUrl = viewModel?.artworkUrl else { return }
        NSWorkspace.shared.open(artworkUrl)
    }
}

//MARK: - Overlay Delegate

extension CoverArtCollectionViewItem: OverlayDelegate {
    
    func mouseEntered() {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.25
            context.allowsImplicitAnimation = true
            contentView.isHidden = false
        }
    }
    
    func mouseExited() {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.25
            context.allowsImplicitAnimation = true
            contentView.isHidden = true
        }
        
        resetCopyButton()
        resetDownloadButton()
    }
}

//MARK: - Content View

fileprivate final class ContentView: NSView {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let start = NSColor.black.withAlphaComponent(0.15)
        if let gradient = NSGradient(colors: [start,
                                              start,
                                              start,
                                              start,
                                              NSColor.black.withAlphaComponent(0.3),
                                              NSColor.black.withAlphaComponent(0.6),
                                              NSColor.black.withAlphaComponent(0.95),
                                              NSColor.black.withAlphaComponent(0.95)]) {
            gradient.draw(in: bounds, angle: 270)
        }
    }
}

fileprivate final class CoverImageView: NSImageView {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Update the border for light/dark mode
        layer?.borderColor = NSColor.coverBorder.cgColor
        layer?.borderWidth = 1
    }
}

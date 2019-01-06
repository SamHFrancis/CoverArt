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
            
            let size = CGSize(width: 420, height: 420 / viewModel.imageAspectRatio)
            let processor = DownsamplingImageProcessor(size: size)
            coverArtImageView.kf.indicatorType = .activity
            let options: KingfisherOptionsInfo = [
                .processor(processor),
                .scaleFactor(NSScreen.main!.backingScaleFactor),
                .cacheMemoryOnly,
                .onFailureImage(viewModel.placeholderImage)
            ]
            
            coverArtImageView.kf.setImage(with: viewModel.artworkUrlSmall,
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
        
        overlay.addSubview(contentView)
        contentView.topAnchor.constraint(equalTo: overlay.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: overlay.bottomAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: overlay.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: overlay.trailingAnchor).isActive = true
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
        copyButton.action = #selector(copyLinkClicked)
        
        browserButton.target = self
        browserButton.action = #selector(browserClicked)
        
        downloadButton.target = self
        downloadButton.action = #selector(downloadClicked)
        
        view.addSubview(overlay)
        overlay.topAnchor.constraint(equalTo: coverArtImageView.topAnchor).isActive = true
        overlay.bottomAnchor.constraint(equalTo: coverArtImageView.bottomAnchor).isActive = true
        overlay.leadingAnchor.constraint(equalTo: coverArtImageView.leadingAnchor).isActive = true
        overlay.trailingAnchor.constraint(equalTo: coverArtImageView.trailingAnchor).isActive = true
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
        guard let trackName = viewModel?.trackName,
            let artworkUrl = viewModel?.artworkUrl else { return }
        
        viewModel?.isDownloading = true
        showDownloading()
        URLSession.shared.dataTask(with: artworkUrl) { [weak self] data, response, error in
            guard let self = self else { return }
            self.viewModel?.isDownloading = false
            
            guard let data = data else {
                if let error = error {
                    print(error)
                }
                
                DispatchQueue.main.async { [weak self] in
                    self?.showDownloadError()
                }
                
                return
            }
            
            do {
                let fileManager = FileManager.default
                
                let downloadsDirectory = try fileManager.url(for: .downloadsDirectory,
                                                             in: .userDomainMask,
                                                             appropriateFor: nil,
                                                             create: true)
                
                var fileUrl = downloadsDirectory
                    .appendingPathComponent(trackName)
                    .appendingPathExtension("jpg")
                
                let searchFile = { (url: URL) in
                    url.absoluteString.dropFirst("file://".count).removingPercentEncoding!
                }
                
                var iteration = 0
                while fileManager.fileExists(atPath: searchFile(fileUrl)) {
                    iteration += 1
                    fileUrl = downloadsDirectory
                        .appendingPathComponent(trackName + "-\(iteration)")
                        .appendingPathExtension("jpg")
                }
                
                try data.write(to: fileUrl)
                
                DispatchQueue.main.async { [weak self] in
                    self?.showDownloaded()
                }
            } catch let e {
                print(e)
                DispatchQueue.main.async { [weak self] in
                    self?.showDownloadError()
                }
            }
            }
            .resume()
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
        if let gradient = NSGradient(colors: [start, start, start, NSColor.black.withAlphaComponent(0.9)]) {
            gradient.draw(in: bounds, angle: 270)
        }
    }
}

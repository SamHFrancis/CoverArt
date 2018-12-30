//
//  OverlayView.swift
//  CoverArt
//
//  Created by Sam Francis on 12/29/18.
//  Copyright © 2018 SamFrancis. All rights reserved.
//

import Cocoa

protocol OverlayDelegate: class {
    func overlayClicked()
}

final class OverlayView: NSView {
    
    weak var delegate: OverlayDelegate?
    
    private var trackingArea: NSTrackingArea?
    
    private let contentView: ContentView = {
        let overlayView = ContentView()
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        return overlayView
    }()
    
    lazy var copyButton: NSButton = {
        let button = NSButton(image: #imageLiteral(resourceName: "link"), target: self, action: #selector(copyClicked))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentTintColor = .labelColor
        return button
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
        
        contentView.addSubview(copyButton)
        copyButton.leadingAnchor
            .constraint(equalTo: contentView.leadingAnchor, constant: 12)
            .isActive = true
        
        copyButton.bottomAnchor
            .constraint(equalTo: contentView.bottomAnchor, constant: -12)
            .isActive = true
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
        contentView.label.isHidden = false
    }
    
    func showCopy() {
        contentView.label.isHidden = true
    }
    
    @objc func copyClicked() {
        delegate?.overlayClicked()
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
        
        showCopy()
    }
    
    private final class ContentView: NSView {
        
        let label: NSTextField = {
            let label = NSTextField(labelWithString: "Copied ✅")
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textColor = .white
            label.font = NSFont.systemFont(ofSize: 18, weight: .medium)
            return label
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
            addSubview(label)
            label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        }
        
        override func draw(_ dirtyRect: NSRect) {
            super.draw(dirtyRect)
            NSColor.black.withAlphaComponent(0.5).setFill()
            dirtyRect.fill()
        }
    }
    
}

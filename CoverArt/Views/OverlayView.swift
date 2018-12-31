//
//  OverlayView.swift
//  CoverArt
//
//  Created by Sam Francis on 12/29/18.
//  Copyright © 2018 SamFrancis. All rights reserved.
//

import Cocoa

protocol OverlayDelegate: class {
    func mouseEntered()
    func mouseExited()
}

final class OverlayView: NSView {
    
    weak var delegate: OverlayDelegate?
    
    private var trackingArea: NSTrackingArea?
    
    override func layout() {
        super.layout()
        if let currentTrackingArea = trackingArea {
            removeTrackingArea(currentTrackingArea)
        }
        
        let newTrackingArea = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeInActiveApp], owner: self, userInfo: nil)
        addTrackingArea(newTrackingArea)
        trackingArea = newTrackingArea
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        delegate?.mouseEntered()
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        delegate?.mouseExited()
    }
    
}

//
//  WindowController.swift
//  CoverArt
//
//  Created by Sam Francis on 12/28/18.
//  Copyright © 2018 SamFrancis. All rights reserved.
//

import Cocoa
import Foundation

class WindowController: NSWindowController {
    
    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var popUpButton: NSPopUpButton!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        shouldCascadeWindows = true
        (NSApplication.shared.delegate as! AppDelegate).windowControllers.insert(self)
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        if let defaultFrameString = UserDefaults.standard.string(forKey: UserDefaults.newWindowSize) {
            print("New Frame: \(defaultFrameString)")
            window?.setFrame(NSRectFromString(defaultFrameString), display: true)
        }
        
        window?.delegate = self
        searchField.delegate = self
        
        popUpButton.removeAllItems()
        
        MediaType.allCases
            .map { $0.displayString }
            .forEach(popUpButton.addItem)
        
        searchField.becomeFirstResponder()
        
        window?.title = "Empty Search"
    }
    
    @IBAction override func newWindowForTab(_ sender: Any?) {
        let newWindow = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
            .instantiateInitialController() as! WindowController
        window?.addTabbedWindow(newWindow.window!, ordered: .above)
    }
    
}

extension WindowController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.windowControllers.remove(self)
    }
    
    func windowDidResize(_ notification: Notification) {
        updateDefaultWindowFrame()
    }
    
    func windowDidMove(_ notification: Notification) {
        updateDefaultWindowFrame()
    }
    
    func updateDefaultWindowFrame() {
        guard self == (NSApplication.shared.delegate as! AppDelegate).newestWindowController else { return }
        guard let frame = window?.frame else { return }
        print("Updated Frame: \(frame)")
        UserDefaults.standard.set(NSStringFromRect(frame), forKey: UserDefaults.newWindowSize)
    }
}

extension WindowController: NSSearchFieldDelegate {
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        guard let viewController = contentViewController as? ViewController else { return false }
        
        switch commandSelector {
        case #selector(NSResponder.insertNewline(_:)):
            let term = searchField.stringValue
            window?.title = term.isEmpty ? "Empty Search" : term
            let mediaType = MediaType.allCases[popUpButton.indexOfSelectedItem]
            viewController.search(term: term, mediaType: mediaType)
            return true
        case #selector(NSResponder.cancelOperation(_:)):
            window?.makeFirstResponder(nil)
            return true
        case #selector(NSResponder.deleteForward(_:)): fallthrough
        case #selector(NSResponder.deleteBackward(_:)): fallthrough
        case #selector(NSResponder.insertTab(_:)): fallthrough
        default:
            return false
        }
    }
    
}

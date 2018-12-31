//
//  WindowController.swift
//  CoverArt
//
//  Created by Sam Francis on 12/28/18.
//  Copyright © 2018 SamFrancis. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {
    
    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var popUpButton: NSPopUpButton!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        shouldCascadeWindows = true
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        searchField.delegate = self
        
        popUpButton.removeAllItems()
        
        MediaType.allCases
            .map { $0.displayString }
            .forEach(popUpButton.addItem)
        
        searchField.becomeFirstResponder()
    }
    
    @IBAction override func newWindowForTab(_ sender: Any?) {
        let newWindow = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
            .instantiateInitialController() as! WindowController
        window?.addTabbedWindow(newWindow.window!, ordered: .above)
    }
    
}

extension WindowController: NSSearchFieldDelegate {
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        guard let viewController = contentViewController as? ViewController else { return false }
        
        switch commandSelector {
        case #selector(NSResponder.insertNewline(_:)):
            let term = searchField.stringValue
            window?.title = term
            let mediaType = MediaType.allCases[popUpButton.indexOfSelectedItem]
            viewController.search(term: term, mediaType: mediaType)
            return true
        case #selector(NSResponder.deleteForward(_:)): fallthrough
        case #selector(NSResponder.deleteBackward(_:)): fallthrough
        case #selector(NSResponder.insertTab(_:)): fallthrough
        case #selector(NSResponder.cancelOperation(_:)): fallthrough
        default:
            return false
        }
    }
    
}

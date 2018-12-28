//
//  AppDelegate.swift
//  CoverArt
//
//  Created by Sam Francis on 12/26/18.
//  Copyright © 2018 SamFrancis. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBAction func newWindow(_ sender: Any) {
        guard let newWindow = newWindowController().window else { return }
        newWindow.makeKeyAndOrderFront(sender)
    }
    
    @IBAction func newTab(_ sender: Any) {
        guard let keyWindow = NSApplication.shared.keyWindow,
            let newTab = newWindowController().window else { return }
        keyWindow.addTabbedWindow(newTab, ordered: .above)
        newTab.makeKeyAndOrderFront(sender)
    }
    
    func newWindowController() -> WindowController {
        return NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
            .instantiateInitialController() as! WindowController
    }
}


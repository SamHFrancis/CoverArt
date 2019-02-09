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
    var windowControllers = Set<WindowController>()
    weak var newestWindowController: WindowController?
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if windowControllers.isEmpty {
            newWindow(sender)
        }
        
        return true
    }
    
    @IBAction func newWindow(_ sender: Any) {
        let newController = newWindowController()
        guard let newWindow = newController.window else { return }
        newestWindowController = newController
        newWindow.makeKeyAndOrderFront(sender)
    }
    
    @IBAction func newTab(_ sender: Any) {
        guard let keyWindow = NSApplication.shared.keyWindow,
            let newTab = newWindowController().window else { return }
        keyWindow.addTabbedWindow(newTab, ordered: .above)
        newTab.makeKeyAndOrderFront(sender)
    }
    
    @IBAction func find(_ sender: Any) {
        guard let windowController = NSApplication.shared.keyWindow?.windowController as? WindowController else { return }
        windowController.searchField.becomeFirstResponder()
    }
    
    func newWindowController() -> WindowController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateInitialController() as! WindowController
        return windowController
    }
}


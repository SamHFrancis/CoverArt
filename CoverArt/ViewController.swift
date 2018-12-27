//
//  ViewController.swift
//  CoverArt
//
//  Created by Sam Francis on 12/26/18.
//  Copyright © 2018 SamFrancis. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var searchField: NSSearchField!
    
    var mediaItems = [MediaItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func search(_ text: String) {
        WebService.fetchMediaItems(term: text) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let mediaItems):
                self.mediaItems = mediaItems
                print(self.mediaItems)
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
}

extension ViewController: NSSearchFieldDelegate {
    func searchFieldDidStartSearching(_ sender: NSSearchField) {
//        print("start")
    }
    
    func searchFieldDidEndSearching(_ sender: NSSearchField) {
//        print("end")
    }
    
    func controlTextDidChange(_ obj: Notification) {
//        print(searchField.stringValue)
    }
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        switch commandSelector {
        case #selector(NSResponder.insertNewline(_:)):
            search(searchField.stringValue)
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

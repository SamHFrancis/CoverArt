//
//  ViewController.swift
//  CoverArt
//
//  Created by Sam Francis on 12/26/18.
//  Copyright © 2018 SamFrancis. All rights reserved.
//

import Cocoa

final class ViewController: NSViewController {
    
    @IBOutlet private weak var searchField: NSSearchField!
    @IBOutlet private weak var collectionView: NSCollectionView!
    
    private var mediaItems = [MediaItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        let layout = NSCollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView.collectionViewLayout = layout
        collectionView.allowsMultipleSelection = false
        collectionView.isSelectable = true
        collectionView.register(CoverArtCollectionViewItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CoverArtCollectionViewItem"))
    }

    func search(_ text: String) {
        WebService.fetchMediaItems(term: text) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let mediaItems):
                self.mediaItems = mediaItems
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
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

extension ViewController: NSCollectionViewDataSource {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaItems.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CoverArtCollectionViewItem"), for: indexPath)
        
        guard let coverArtItem = item as? CoverArtCollectionViewItem else {
            return item
        }
        
        coverArtItem.representedObject = mediaItems[indexPath.item]
        
        return coverArtItem
    }
}

extension ViewController: NSCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        return CGSize(width: 100, height: 100)
    }
}

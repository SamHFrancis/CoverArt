//
//  ViewController.swift
//  CoverArt
//
//  Created by Sam Francis on 12/26/18.
//  Copyright © 2018 SamFrancis. All rights reserved.
//

import Cocoa
import Kingfisher

final class ViewController: NSViewController {
    @IBOutlet private weak var collectionView: NSCollectionView!
    @IBOutlet private weak var activityIndicator: NSProgressIndicator!
    @IBOutlet private weak var emptyStateLabel: NSTextField!
    
    private var mediaItems = [MediaItem]()
    private var mediaType: MediaType = .movie
    private var prefetcher: ImagePrefetcher?
    
    private var windowControler: WindowController? {
        return view.window?.windowController as? WindowController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        collectionView.register(CoverArtCollectionViewItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CoverArtCollectionViewItem"))
        emptyStateLabel.isHidden = true
    }
    
    override func viewWillLayout() {
        super.viewWillLayout()
        collectionView.collectionViewLayout?.invalidateLayout()
    }

    func search(term: String, mediaType: MediaType) {
        self.mediaType = mediaType
        emptyStateLabel.isHidden = true
        mediaItems = []
        collectionView.reloadData()
        
        guard !term.isEmpty else { return }
        
        activityIndicator.startAnimation(nil)
        WebService.fetchMediaItems(term: term, mediaType: mediaType) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimation(nil)
                
                switch result {
                case .success(let mediaItems):
                    self.mediaItems = mediaItems
                    self.collectionView.reloadData()
                    if mediaItems.isEmpty {
                        self.emptyStateLabel.isHidden = false
                    }
                case .failure(let error):
                    self.emptyStateLabel.isHidden = false
                    print("Error: \(error)")
                }
            }
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

fileprivate let minColumnWidth: CGFloat = 200
fileprivate let columnSpacing: CGFloat = 20
fileprivate let rowSpacing: CGFloat = 32

extension ViewController: NSCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        let numberOfColumns = (collectionView.bounds.width - columnSpacing) / (minColumnWidth + columnSpacing)
        let width = ((collectionView.bounds.width - columnSpacing) / floor(numberOfColumns)) - columnSpacing
        return CGSize(width: width, height: (width / mediaType.imageAspectRatio) + 27)
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, insetForSectionAt section: Int) -> NSEdgeInsets {
        return NSEdgeInsets(top: columnSpacing, left: columnSpacing, bottom: columnSpacing, right: columnSpacing)
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return rowSpacing
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return columnSpacing
    }
}

extension ViewController: NSCollectionViewPrefetching {
    func collectionView(_ collectionView: NSCollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.map { mediaItems[$0.item].artworkUrlSmall }
        prefetcher = ImagePrefetcher(urls: urls)
        prefetcher?.start()
    }
    
    func collectionView(_ collectionView: NSCollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        prefetcher?.stop()
    }
}

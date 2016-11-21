//
//  KMReaderPageJumpCollectionItem.swift
//  Komikan
//
//  Created by Seth on 2016-03-20.
//

import Cocoa

class KMReaderPageJumpCollectionItem: NSCollectionViewItem {

    /// The image view for the thumbnail
    @IBOutlet var thumbnailImageView: KMRasterizedImageView!
    
    override func mouseDown(with theEvent: NSEvent) {
        // Jump to this page
        (self.representedObject as! KMReaderPageJumpGridItem).readerViewController.jumpToPage((self.representedObject as! KMReaderPageJumpGridItem).page, round: false);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        // Do view setup here.
        
        // Bind the alpha value of the thumbnail to if it is the current page
        self.thumbnailImageView.bind("alphaValue", to: self, withKeyPath: "representedObject.alpha", options: nil);
    }
}

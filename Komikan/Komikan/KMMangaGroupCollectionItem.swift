//
//  KMMangaGroupCollectionItem.swift
//  Komikan
//
//  Created by Seth on 2016-03-16.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

class KMMangaGroupCollectionItem: NSCollectionViewItem {

    override func mouseDown(theEvent: NSEvent) {
        // Select this item
        self.selected = true;
        
        // Set the collection view to be frontmost
        NSApplication.sharedApplication().windows.first!.makeFirstResponder(self.collectionView);
        
        // If we double clicked...
        if(theEvent.clickCount == 2) {
            print((self.representedObject as! KMMangaGroupItem).groupName);
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
}

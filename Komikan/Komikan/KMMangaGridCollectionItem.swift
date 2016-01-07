//
//  KMMangaGridItemView.swift
//  Komikan
//
//  Created by Seth on 2016-01-07.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

class KMMangaGridCollectionItem: NSCollectionViewItem {
    override func mouseDown(theEvent: NSEvent) {
        if(theEvent.clickCount == 2) {
            print("Mouse down");
        }
    }
}

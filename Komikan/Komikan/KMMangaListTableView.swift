//
//  KMMangaListTableView.swift
//  Komikan
//
//  Created by Seth on 2016-03-01.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

class KMMangaListTableView: NSTableView {
    
    /// A reference to the manga list controller
    var mangaListController : KMMangaListController?;

    override func rightMouseDown(theEvent: NSEvent) {
        // If the manga list has any items selected...
        if(self.selectedRow != -1) {
            // Open the popover for the selected item
            mangaListController!.openPopover(false, manga: mangaListController!.selectedManga());
        }
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
}
